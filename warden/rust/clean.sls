# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}

Rust toolchain is removed for user '{{ warden.lookup.user }}':
  cmd.run:
    - name: rustup toolchain uninstall nightly
    - runas: {{ warden.lookup.user }}

Rustup is removed for user '{{ warden.lookup.user }}':
  file.absent:
    - name: {{ salt['user.info'](warden.lookup.user).home | path_join('.rustup') }}
