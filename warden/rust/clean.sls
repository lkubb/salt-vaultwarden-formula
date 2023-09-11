# vim: ft=sls

{#-
    Uninstalls the Rust toolchain.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_clean = tplroot ~ ".config.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}
{%- set user_info = salt["user.info"](warden.lookup.user.name) %}
{%- if user_info %}

Rust toolchain is removed for user '{{ warden.lookup.user.name }}':
  cmd.run:
    - name: rustup self uninstall -y
    - runas: {{ warden.lookup.user.name }}
    - onlyif:
      - test -d '{{ user_info.home | path_join(".rustup") }}'
{%- endif %}
