# vim: ft=sls

{#-
    Stops the warden service and disables it at boot time.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}

Vaultwarden is dead:
  service.dead:
    - name: {{ warden.lookup.service.name }}
    - enable: false
