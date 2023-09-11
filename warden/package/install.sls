# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}
{%- set sls_require_rust = "" %}

{%- if not warden.install.source and warden.rust_setup %}
include:
{%-   if warden.rust_setup is boolean %}
{%-     set sls_require_rust = tplroot ~ ".rust.install" %}
{%-   else %}
{%-     set sls_require_rust = warden.rust_setup %}
{%-   endif %}
  - {{ sls_require_rust }}
{%- endif %}

Vaultwarden user/group are present:
  group.present:
    - name: {{ warden.lookup.user.group }}
    - gid: {{ warden.lookup.user.gid }}
    - system: true
  user.present:
    - name: {{ warden.lookup.user.name }}
    - home: {{ warden.lookup.paths.home if (not warden.install.source and warden.rust_setup) else warden.lookup.paths.data }}
    - uid: {{ warden.lookup.user.uid }}
    - createhome: true
    - fullname: Vaultwarden Server
    - system: true
    - usergroup: {{ warden.lookup.user.group == warden.lookup.user.name }}
    - gid: {{ warden.lookup.user.group }}
    - require:
      - group: {{ warden.lookup.user.group }}

Vaultwarden user paths are setup:
  file.directory:
    - names:
{%- for dir in ["attachments", "bin", "build", "data", "icon_cache", "log", "sends", "web_vault"] %}
      - {{ warden.lookup.paths[dir] }}
{%- endfor %}
      - {{ warden.lookup.paths.conf }}:
        - user: root
        - group: {{ warden.lookup.user.group }}
        - mode: '0750'
    - user: {{ warden.lookup.user.name }}
    - group: {{ warden.lookup.user.group }}
    - mode: '0710'
    - makedirs: true
    - require:
      - Vaultwarden user/group are present

Requirements for compiling/running vaultwarden are installed:
  pkg.installed:
    - pkgs: {{ warden._deps }}
{%- if sls_require_rust %}
    - require:
      - sls: {{ sls_require_rust }}
{%- endif %}

{%- if not warden.install.source %}

Vaultwarden repository is up to date:
  git.latest:
    - name: {{ warden.lookup.pkg.source }}
    - target: {{ warden.lookup.paths.build }}
    - rev: {{ warden.version }}
    - force_reset: true
    - user: {{ warden.lookup.user.name }}
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
    - runas: {{ warden.lookup.user.name }}
    - require:
      - Requirements for compiling/running vaultwarden are installed
    - onchanges:
      - Vaultwarden repository is up to date
      - Trigger build unless version matches

Vaultwarden binary is installed:
  file.copy:
    - name: {{ warden.lookup.paths.bin | path_join("vaultwarden") }}
    - source: {{ warden.lookup.paths.build | path_join("target", "release", "vaultwarden") }}
    - user: {{ warden.lookup.user.name }}
    - group: {{ warden.lookup.user.group }}
    - force: true
    - onchanges:
      - Vaultwarden is compiled from source
{%- else %}

Vaultwarden binary is installed:
  file.managed:
    - name: {{ warden.lookup.paths.bin | path_join("vaultwarden") }}
    - source:
{%-   set sources = warden.install.source %}
{%-   if not sources | is_list %}
{%-     set sources = [sources] %}
{%-   endif %}
{%-   for src in sources %}
      - {{ src.format(version=warden.version) }}
{%-   endfor %}
{%-   for param, val in warden.install.items() %}
{%-     if param in ["source", "user", "group", "name", "mode"] %}
{%-       continue %}
{%-     endif %}
    - {{ param }}: {{ val.format(version=warden.version) if val is string else val | json }}
{%-   endfor %}
    - user: {{ warden.lookup.user.name }}
    - group: {{ warden.lookup.user.group }}
    - mode: '0755'
{%- endif %}

Vaultwarden service unit is installed:
  file.managed:
    - name: {{ warden.lookup.service.unit.format(name=warden.lookup.service.name) }}
    - source: {{ files_switch(
                    ["vaultwarden.service", "vaultwarden.service.j2"],
                    config=warden,
                    lookup="Vaultwarden service unit is installed",
                  )
              }}
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
                    ["logrotate", "logrotate.j2"],
                    config=warden,
                    lookup="Logrotate is setup for vaultwarden",
                  )
              }}
    - template: jinja
    - mode: '0644'
    - user: root
    - group: {{ warden.lookup.rootgroup }}
    - makedirs: true
    - context: {{ {"warden": warden} | json }}
    - require:
      - Vaultwarden binary is installed
{%- endif %}
