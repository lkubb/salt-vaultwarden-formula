# vim: ft=sls

{#-
    Uninstalls the Rust toolchain.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_clean = tplroot ~ ".config.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}
{%- set home = salt["user.info"](warden.lookup.user).home %}

Rust toolchain is removed for user '{{ warden.lookup.user }}':
  cmd.run:
    - name: rustup self uninstall -y
    - runas: {{ warden.lookup.user }}
    - onlyif:
      - test -d '{{ home | path_join(".rustup") }}'
