# vim: ft=sls

{#-
    *Meta-state*.

    This installs the warden package,
    manages the warden configuration file
    and then starts the associated warden service.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}

include:
  - .package
  - .config
  - .cert
{%- if warden.version_web_vault %}
  - .web_vault
{%- endif %}
  - .service
