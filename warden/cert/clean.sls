# vim: ft=sls

{#-
    Removes generated Vaultwarden TLS certificate + key.
    Depends on `warden.service.clean`_.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_service_clean = tplroot ~ ".service.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}

include:
  - {{ sls_service_clean }}

{%- if warden.cert.generate %}

Vaultwarden key/cert is absent:
  file.absent:
    - names:
      - {{ warden.lookup.cert.privkey }}
      - {{ warden.lookup.cert.cert }}
    - require:
      - sls: {{ sls_service_clean }}
{%- endif %}
