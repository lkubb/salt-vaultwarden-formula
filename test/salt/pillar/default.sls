# -*- coding: utf-8 -*-
# vim: ft=yaml
---
warden:
  lookup:
    master: template-master
    # Just for testing purposes
    winner: lookup
    added_in_lookup: lookup_value
    config: '/etc/opt/vaultwarden/vaultwarden.conf'
    service:
      name: vaultwarden
    gpg:
      key: B9B7A108373276BF3C0406F9FC8A7D14C3CD543A
      server: pgp.rediris.es
    group: vaultwarden
    paths:
      attachments: /opt/vaultwarden/data/attachments
      bin: /opt/vaultwarden
      build: /opt/vaultwarden/src
      conf: /etc/opt/vaultwarden
      data: /opt/vaultwarden/data
      home: /home/vaultwarden
      icon_cache: /opt/vaultwarden/data/icon_cache
      log: /opt/vaultwarden/log
      rsa_keyfile: /opt/vaultwarden/data/rsa_key
      sends: /opt/vaultwarden/data/sends
      web_vault: /opt/vaultwarden/web-vault
    pkg:
      latest: https://github.com/dani-garcia/vaultwarden/releases/latest/
      source: https://github.com/dani-garcia/vaultwarden.git
    requirements:
      base:
        - build-essential
        - git
        - pkg-config
        - libssl-dev
      gpg:
        - gpg
        - python3-gnupg
      mysql:
        - libmariadb-dev-compat
        - libmariadb-dev
      postgresql:
        - libpq-dev
        - pkg-config
      sqlite:
        - libsqlite3-dev
    rustup_init:
      source: https://sh.rustup.rs
      source_hash: a3cb081f88a6789d104518b30d4aa410009cd08c3822a1226991d6cf0442a0f8
    service:
      name: vaultwarden
      unit: /etc/systemd/system/{name}.service
    user: vaultwarden
    web_vault:
      latest: https://github.com/dani-garcia/bw_web_builds/releases/latest/
      sig: https://github.com/dani-garcia/bw_web_builds/releases/download/v{version}/bw_web_v{version}.tar.gz.asc
      source: https://github.com/dani-garcia/bw_web_builds/releases/download/v{version}/bw_web_v{version}.tar.gz
  config:
    admin_token: ''
    database_url: data/db.sqlite3
    disable_icon_download: false
    domain: http://vault.example.com
    signups_allowed: true
    signups_domains_whitelist:
      - example.com
      - example.net
      - example.org
    signups_verify: false
    templates_folder: /path/to/templates
    web_vault_enabled: true
  features:
    - mysql
    - postgresql
    - sqlite
  rust_setup: true
  service:
    requires_mount: []
    wants: []
  version: latest
  version_web_vault: latest

  tofs:
    # The files_switch key serves as a selector for alternative
    # directories under the formula files directory. See TOFS pattern
    # doc for more info.
    # Note: Any value not evaluated by `config.get` will be used literally.
    # This can be used to set custom paths, as many levels deep as required.
    files_switch:
      - any/path/can/be/used/here
      - id
      - roles
      - osfinger
      - os
      - os_family
    # All aspects of path/file resolution are customisable using the options below.
    # This is unnecessary in most cases; there are sensible defaults.
    # Default path: salt://< path_prefix >/< dirs.files >/< dirs.default >
    #         I.e.: salt://warden/files/default
    # path_prefix: template_alt
    # dirs:
    #   files: files_alt
    #   default: default_alt
    # The entries under `source_files` are prepended to the default source files
    # given for the state
    # source_files:
    #   warden-config-file-file-managed:
    #     - 'example_alt.tmpl'
    #     - 'example_alt.tmpl.jinja'

    # For testing purposes
    source_files:
      warden-config-file-file-managed:
        - 'example.tmpl.jinja'
      warden-web_vault-config-file-file-managed:
        - 'web_vault-example.tmpl.jinja'

  # Just for testing purposes
  winner: pillar
  added_in_pillar: pillar_value
