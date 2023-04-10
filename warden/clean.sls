# vim: ft=sls

{#-
    *Meta-state*.

    Undoes everything performed in the ``warden`` meta-state
    in reverse order, i.e.
    stops the service,
    removes the configuration file and then
    uninstalls the package.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}

include:
  - .service.clean
{%- if warden.version_web_vault %}
  - .web_vault.clean
{%- endif %}
  - .config.clean
  - .package.clean
