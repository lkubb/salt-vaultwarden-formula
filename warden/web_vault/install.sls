# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}

Salt can manage gpg for vaulwarden web vault:
  pkg.installed:
    - pkgs: {{ warden.lookup.requirements.gpg | json }}
  cmd.run:
    - name: gpg --list-keys
    - unless:
      - test -d /root/.gnupg

# I could find the key on keys.openpgpg.org, but gpg does not
# import it (no user ID). Seems only pgp.rediris.es has
# it as required atm, so I included it in `files` for reference.
# Salt still reported it as present, although gpg did not import it.
Vaultwarden signing key is present (from keyserver):
  gpg.present:
    - name: {{ warden.lookup.gpg.key }}
    - keyserver: {{ warden.lookup.gpg.server }}
    - require:
      - Salt can manage gpg for vaulwarden web vault

Vaultwarden signing key is present (fallback):
  file.managed:
    - name: /tmp/vw-key.asc
    - source: salt://warden/files/default/key.asc
    - onfail:
      - Vaultwarden signing key is present (from keyserver)
  module.run:
    - gpg.import_key:
      - filename: /tmp/vw-key.asc
    - onfail:
      - Vaultwarden signing key is present (from keyserver)
    - require:
      - file: /tmp/vw-key.asc

# Fun fact:
# When the signature cannot be verified because the key is missing,
# `gpg.verify` just returns true. Huh. Unexpected.
# I should definitely write a function for the state module.
Vaultwarden key is actually present:
  module.run:
    - gpg.get_key:
      - fingerprint: {{ warden.lookup.gpg.key }}

Vaultwarden web vault is downloaded:
  file.managed:
    - names:
      - /tmp/web-vault-{{ warden.version_web_vault }}.tar.gz:
        - source: {{ warden.lookup.web_vault.source.format(version=warden.version_web_vault) }}
      - /tmp/web-vault-{{ warden.version_web_vault }}.tar.gz.asc:
        - source: {{ warden.lookup.web_vault.sig.format(version=warden.version_web_vault) }}
    - skip_verify: true
    - require:
      - Vaultwarden key is actually present

Vaultwarden web vault signature is verified:
  module.run:
    - gpg.verify:
      - filename: /tmp/web-vault-{{ warden.version_web_vault }}.tar.gz
      - signature: /tmp/web-vault-{{ warden.version_web_vault }}.tar.gz.asc
    - require:
      - Vaultwarden key is actually present
      - Vaultwarden web vault is downloaded

Vaultwarden web is removed if signature verification failed:
  file.absent:
    - names:
      - /tmp/web-vault-{{ warden.version_web_vault }}.tar.gz
      - /tmp/web-vault-{{ warden.version_web_vault }}.tar.gz.asc
    - onfail:
      - Vaultwarden web vault signature is verified

Vaultwarden web vault is extracted:
  archive.extracted:
    - name: {{ warden.lookup.paths.web_vault }}
    - source: /tmp/web-vault-{{ warden.version_web_vault }}.tar.gz
    - user: {{ warden.lookup.user }}
    - group: {{ warden.lookup.group }}
    - force: true
    # just dump the files
    - options: --strip-components=1
    # this is needed because of the above
    - enforce_toplevel: false
    - require:
      - Vaultwarden web vault signature is verified
    - onchanges:
      - Vaultwarden web vault is downloaded
