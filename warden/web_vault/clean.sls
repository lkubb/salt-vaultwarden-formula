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
