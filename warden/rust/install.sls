# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}
{%- set rustup_init = warden.lookup.paths.home | path_join('rustup-init') %}

Rustup-init is available:
  file.managed:
    - name: {{ rustup_init }}
    - source: {{ warden.lookup.rustup_init.source }}
    - source_hash: {{ warden.lookup.rustup_init.source_hash }}
    - user: {{ warden.lookup.user }}
    - group: {{ warden.lookup.group }}
    - makedirs: true
    - mode: '0755'
    - require:
      - Vaultwarden user/group are present
    - unless:
      - sudo -iu '{{ warden.lookup.user }}' command -v rustup

Rustup is installed for user '{{ warden.lookup.user }}':
  cmd.run:
    - name: {{ rustup_init }} -y
    - runas: {{ warden.lookup.user }}
    - require:
      - Rustup-init is available
    - prereq:
      - Rustup-init is absent
    - onchanges:
      - Rustup-init is available

Rust toolchain is installed for user '{{ warden.lookup.user }}':
  cmd.run:
    # apparently, Rust nightly is a dependency:
    # https://github.com/dani-garcia/vaultwarden/wiki/Building-binary
    # I don't think that's the best idea here, should be fine
    # with stable.
    - name: rustup toolchain install stable
    - runas: {{ warden.lookup.user }}
    - require:
      - Rustup is installed for user '{{ warden.lookup.user }}'

Rustup-init is absent:
  file.absent:
    - name: {{ rustup_init }}
