# vim: ft=sls

{#-
    Removes the configuration of the warden service and has a
    dependency on `warden.service.clean`_.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_service_clean = tplroot ~ ".service.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}

include:
  - {{ sls_service_clean }}

Vaultwarden configuration is absent:
  file.absent:
    - name: {{ warden.lookup.paths.conf | path_join("vaultwarden.conf") }}
    - require:
      - sls: {{ sls_service_clean }}
