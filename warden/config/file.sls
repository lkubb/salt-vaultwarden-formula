# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

Vaultwarden configuration is managed:
  file.managed:
    - name: {{ warden.lookup.paths.conf | path_join("vaultwarden.conf") }}
    - source: {{ files_switch(
                    ["vaultwarden.conf", "vaultwarden.conf.j2"],
                    config=warden,
                    lookup="Vaultwarden configuration is managed"
                 )
              }}
    - mode: '0600'
    - user: root
    - group: {{ warden.lookup.rootgroup }}
    - makedirs: true
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        warden: {{ warden | json }}
