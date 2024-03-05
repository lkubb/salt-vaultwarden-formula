# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

{#- very crude onedir check – relenv pythonexecutable does not end with `run` #}
{%- set onedir = grains.pythonexecutable.startswith("/opt/saltstack") %}

Salt deps for vaultwarden web vault:
{%- if onedir %}
  pip.installed:
    - name: {{ warden.lookup.requirements.gpg.lib.pip }}
{%- endif %}
  pkg.installed:
    - pkgs:
      - {{ warden.lookup.requirements.gpg.pkg }}
      - tar
{%- if not onedir %}
      - {{ warden.lookup.requirements.gpg.lib.pkg }}
{%- endif %}

Vaultwarden signing key is present:
  gpg.present:
    - names:
{%- for key in warden.lookup.gpg["keys"] %}
      - {{ key[-16:] }}
{%- endfor %}
    - keyserver: {{ warden.lookup.gpg.server }}
    - source: {{ files_switch(
                    ["key.asc"],
                    config=warden,
                    lookup="Vaultwarden signing key is present"
                 )
              }}
    - require:
      - Salt deps for vaultwarden web vault

Vaultwarden web vault is extracted:
  archive.extracted:
    - name: {{ warden.lookup.paths.web_vault }}
    - source: {{ warden.lookup.web_vault.source.format(version=warden.version_web_vault) }}
    - source_hash: {{ warden.lookup.web_vault.source_hash.format(version=warden.version_web_vault) }}
    - signature: {{ warden.lookup.web_vault.sig.format(version=warden.version_web_vault) }}
    - signed_by_any: {{ warden.lookup.gpg["keys"] | json }}
    - user: {{ warden.lookup.user.name }}
    - group: {{ warden.lookup.user.group }}
    - force: true
    # just dump the files
    - options: --strip-components=1
    # this is needed because of the above
    - enforce_toplevel: false
    - require:
      - Vaultwarden signing key is present

