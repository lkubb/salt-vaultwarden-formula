# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- set sls_rust_clean = tplroot ~ '.rust.clean' %}
{%- set sls_web_vault_clean = tplroot ~ '.web_vault.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}

include:
  - {{ sls_config_clean }}
{%- if warden.version_web_vault %}
  - {{ sls_web_vault_clean }}
{%- endif %}
{%- if warden.rust_setup %}
  - {{ sls_rust_clean }}
{%- endif %}

Vaultwarden is absent:
  file.absent:
    - names:
      - {{ warden.lookup.service.unit.format(name=warden.lookup.service.name) }}
      - {{ warden.lookup.paths.bin | path_join('vaultwarden') }}
      - {{ warden.lookup.paths.build }}
    - require:
      - sls: {{ sls_config_clean }}
{%- if warden.rust_setup %}
      - sls: {{ sls_rust_clean }}
{%- endif %}
{%- if warden.version_web_vault %}
      - sls: {{ sls_web_vault_clean }}
{%- endif %}

Vaultwarden user/group are absent:
  user.absent:
    - name: {{ warden.lookup.user }}
    - require:
      - Vaultwarden is absent
  group.absent:
    - name: {{ warden.lookup.group }}
    - require:
      - Vaultwarden is absent
