# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}

include:
  - .package
  - .config
{%- if warden.version_web_vault %}
  - .web_vault
{%- endif %}
  - .service
