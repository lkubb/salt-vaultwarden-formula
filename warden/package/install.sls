# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}
{%- set sls_require_rust = "" %}

{%- if warden.rust_setup %}
include:
{%-   if warden.rust_setup is boolean %}
{%-     set sls_require_rust = tplroot ~ ".rust.install" %}
{%-   else %}
{%-     set sls_require_rust = warden.rust_setup %}
{%-   endif %}
  - {{ sls_require_rust }}
{%- endif %}

Vaultwarden user/group are present:
  user.present:
    - name: {{ warden.lookup.user }}
    - home: {{ warden.lookup.paths.home }}
    - createhome: true
    - fullname: Vaultwarden Server
    - system: true
    - usergroup: {{ warden.lookup.group == warden.lookup.user }}
{%- if warden.lookup.group != warden.lookup.user %}
    - gid: {{ warden.lookup.group }}
    - require:
      - group: {{ warden.lookup.group }}
  group.present:
    - name: {{ warden.lookup.group }}
    - system: true
{%- endif %}

Vaultwarden user paths are setup:
  file.directory:
    - names:
{%- for dir in ["attachments", "bin", "build", "data", "icon_cache", "log", "sends", "web_vault"] %}
      - {{ warden.lookup.paths[dir] }}
{%- endfor %}
      - {{ warden.lookup.paths.conf }}:
        - user: root
        - group: {{ warden.lookup.rootgroup }}
        - mode: '0700'
    - user: {{ warden.lookup.user }}
    - group: {{ warden.lookup.group }}
    - mode: '0710'
    - makedirs: true
    - require:
      - Vaultwarden user/group are present

Requirements for compiling vaultwarden are installed:
  pkg.installed:
    - pkgs: {{ warden._deps }}
{%- if sls_require_rust %}
    - require:
      - sls: {{ sls_require_rust }}
{%- endif %}

Vaultwarden repository is up to date:
  git.latest:
    - name: {{ warden.lookup.pkg.source }}
    - target: {{ warden.lookup.paths.build }}
    - rev: {{ warden.version }}
    - force_reset: true
    - user: {{ warden.lookup.user }}
    - require:
      - Vaultwarden user paths are setup

# To avoid situations where a build fails once and then does
# not get retriggered in subsequent runs
Trigger build unless version matches:
  test.succeed_with_changes:
    - unless:
      - test $({{ warden.lookup.paths.bin | path_join("vaultwarden") }} --version | grep -Eo '[0-9\.]+$') = '{{ warden.version }}'
    - require:
      - Vaultwarden repository is up to date

Vaultwarden is compiled from source:
  cmd.run:
    - name: cargo build --features {{ warden.features | join(",") }} --release
    - cwd: {{ warden.lookup.paths.build }}
    - runas: {{ warden.lookup.user }}
    - require:
      - Requirements for compiling vaultwarden are installed
    - onchanges:
      - Vaultwarden repository is up to date
      - Trigger build unless version matches

Vaultwarden binary is installed:
  file.copy:
    - name: {{ warden.lookup.paths.bin | path_join("vaultwarden") }}
    - source: {{ warden.lookup.paths.build | path_join("target", "release", "vaultwarden") }}
    - user: {{ warden.lookup.user }}
    - group: {{ warden.lookup.group }}
    - onchanges:
      - Vaultwarden is compiled from source

Vaultwarden service unit is installed:
  file.managed:
    - name: {{ warden.lookup.service.unit.format(name=warden.lookup.service.name) }}
    - source: {{ files_switch(
                    ["vaultwarden.service.j2"],
                    lookup="Vaultwarden service unit is installed",
                  ) }}
    - template: jinja
    - mode: '0644'
    - user: root
    - group: {{ warden.lookup.rootgroup }}
    - makedirs: true
    - context: {{ {"warden": warden} | json }}
    - require:
      - Vaultwarden binary is installed

# sanity check
Check the current version matches the expected now:
  test.fail_without_changes:
    - unless:
      - test $({{ warden.lookup.paths.bin | path_join("vaultwarden") }} --version | grep -Eo '[0-9\.]+$') = '{{ warden.version }}'
    - require:
      - Vaultwarden binary is installed

{%- if "logrotate" | which %}

Logrotate is setup for vaultwarden:
  file.managed:
    - name: /etc/logrotate.d/vaultwarden
    - source: {{ files_switch(
                    ["logrotate.j2"],
                    lookup="Logrotate is setup for vaultwarden",
                  ) }}
    - template: jinja
    - mode: '0644'
    - user: root
    - group: {{ warden.lookup.rootgroup }}
    - makedirs: true
    - context: {{ {"warden": warden} | json }}
    - require:
      - Vaultwarden binary is installed
{%- endif %}
