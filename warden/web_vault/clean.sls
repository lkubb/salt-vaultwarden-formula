# vim: ft=sls

{#-
    Removes the Web vault.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}

Vaultwarden web vault is absent:
  file.absent:
    - names:
      - {{ warden.lookup.paths.web_vault }}
      # make sure the web vault can be installed again (onchanges req!)
      - /tmp/web-vault-{{ warden.version_web_vault }}.tar.gz
