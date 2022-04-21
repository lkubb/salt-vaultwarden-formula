# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}

warden-service-clean-service-dead:
  service.dead:
    - name: {{ warden.lookup.service.name }}
    - enable: False
