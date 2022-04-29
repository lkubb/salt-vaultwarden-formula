# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}
{%- set rustup_init = salt['temp.file']() %}

Rustup-init is available:
  file.managed:
    - name: {{ rustup_init }}
    - source: {{ warden.lookup.rustup_init.source }}
    - source_hash: {{ warden.lookup.rustup_init.source_hash }}
    - unless:
      - sudo -iu '{{ warden.lookup.user }}' command -v rustup
    - require:
      - Vaultwarden user/group are present

Rustup is installed for user '{{ warden.lookup.user }}':
  cmd.script:
    - name: {{ rustup_init }}
    - args: -y
    - runas: {{ warden.lookup.user }}
    - require:
      - Rustup-init is available
    - prereq:
      - Rustup-init is absent
    - onchanges:
      - Rustup-init is available

# Rust nightly is currently a dependency:
#   https://github.com/dani-garcia/vaultwarden/wiki/Building-binary
# because of the Rocket library:
#   https://github.com/dani-garcia/vaultwarden/issues/712
# This will be resolved in the near future and is already in main:
#   https://github.com/dani-garcia/vaultwarden/pull/2276

# We do not need to explicitly install a specific toolchain,
# rustup will do that automatically. We set default nightly
# to avoid pulling stable first. This will install nightly automatically.
# Once there is a release that builds with stable, change that @FIXME.

Rust toolchain defaults to nightly for user '{{ warden.lookup.user }}':
  cmd.run:
    - name: rustup default nightly
    - runas: {{ warden.lookup.user }}
    # no unless since on the first installation, this will pull stable
    - require:
      - Rustup is installed for user '{{ warden.lookup.user }}'

Rustup-init is absent:
  file.absent:
    - name: {{ rustup_init }}
