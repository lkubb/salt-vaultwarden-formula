# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

warden-config-file-file-managed:
  file.managed:
    - name: {{ warden.lookup.paths.conf | path_join('vaultwarden.conf') }}
    - source: {{ files_switch(['vaultwarden.conf.j2'],
                              lookup='warden-config-file-file-managed'
                 )
              }}
    - mode: '0600'
    - user: root
    - group: {{ warden.lookup.rootgroup }}
    - makedirs: True
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        warden: {{ warden | json }}
