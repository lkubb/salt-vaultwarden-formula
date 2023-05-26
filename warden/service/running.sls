# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_file = tplroot ~ ".config.file" %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}

include:
  - {{ sls_config_file }}


Vaultwarden is running:
  service.running:
    - name: {{ warden.lookup.service.name }}
    - enable: true
    - watch:
      - sls: {{ sls_config_file }}

{%- if warden.manage_firewall and grains["os_family"] == "RedHat" %}

Vaultwarden service is known:
  firewalld.service:
    - name: vaultwarden
    - ports:
      - {{ warden | traverse("config:rocket_port", "8000") }}/tcp
      - {{ warden | traverse("config:websocket_port", "3012") }}/tcp
    - require:
      - Vaultwarden is running

Vaultwarden ports are open:
  firewalld.present:
    - name: public
    - services:
      - vaultwarden
    - require:
      - Vaultwarden service is known
{%- endif %}
