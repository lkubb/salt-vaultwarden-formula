# vim: ft=yaml
---
warden:
  lookup:
    master: template-master
    # Just for testing purposes
    winner: lookup
    added_in_lookup: lookup_value
    config: '/etc/vaultwarden/vaultwarden.conf'
    gpg:
      keys:
        - B9B7A108373276BF3C0406F9FC8A7D14C3CD543A
        - 3C5BBC173D81186CFFDE72A958C80A2AA6C765E1
      server: pgp.mit.edu
    paths:
      attachments: attachments
      bin: /opt/vaultwarden
      build: /opt/vaultwarden/src
      conf: /etc/vaultwarden
      data: /var/lib/vaultwarden
      home: /home/vaultwarden
      icon_cache: icon_cache
      log: /var/log/vaultwarden
      rsa_keyfile: rsa_key
      sends: sends
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
        lib:
          pip: python-gnupg
          pkg: python3-gnupg
        pkg: gpg
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
      source_hash: 41262c98ae4effc2a752340608542d9fe411da73aca5fbe947fe45f61b7bd5cf
    service:
      name: vaultwarden
      unit: /etc/systemd/system/{name}.service
    user:
      gid: 4477
      group: vaultwarden
      name: vaultwarden
      uid: 4477
    web_vault:
      latest: https://github.com/dani-garcia/bw_web_builds/releases/latest/
      sig: https://github.com/dani-garcia/bw_web_builds/releases/download/v{version}/bw_web_v{version}.tar.gz.asc
      source: https://github.com/dani-garcia/bw_web_builds/releases/download/v{version}/bw_web_v{version}.tar.gz
  config:
    admin_token: ''
    database_url: db.sqlite3
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
  install:
    source: []
  manage_firewall: false
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
