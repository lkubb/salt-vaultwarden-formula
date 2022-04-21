# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_service_clean = tplroot ~ '.service.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}

include:
  - {{ sls_service_clean }}

warden-config-clean-file-absent:
  file.absent:
    - name: {{ warden.lookup.paths.conf | path_join('vaultwarden.conf') }}
    - require:
      - sls: {{ sls_service_clean }}
