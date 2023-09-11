# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_file = tplroot ~ ".config.file" %}
{%- from tplroot ~ "/map.jinja" import mapdata as warden with context %}

include:
  - {{ sls_config_file }}

{%- if warden.cert.generate %}

Vaultwarden certificate private key is managed:
  x509.private_key_managed:
    - name: {{ warden.lookup.cert.privkey }}
    - algo: rsa
    - keysize: 2048
    - new: true
{%-   if salt["file.file_exists"](warden.lookup.cert.privkey) %}
    - prereq:
      - Vaultwarden certificate is managed
{%-   endif %}
    - makedirs: true
    - user: {{ warden.lookup.user.name }}
    - group: {{ warden.lookup.user.group }}
    - require:
      - sls: {{ sls_config_file }}

Vaultwarden certificate is managed:
  x509.certificate_managed:
    - name: {{ warden.lookup.cert.cert }}
    - ca_server: {{ warden.cert.ca_server or "null" }}
    - signing_policy: {{ warden.cert.signing_policy or "null" }}
    - signing_cert: {{ warden.cert.signing_cert or "null" }}
    - signing_private_key: {{ warden.cert.signing_private_key or
                              (warden.lookup.cert.privkey if not warden.cert.ca_server and not warden.cert.signing_cert else "null") }}
    - private_key: {{ warden.lookup.cert.privkey }}
    - authorityKeyIdentifier: keyid:always
    - basicConstraints: critical, CA:false
    - subjectKeyIdentifier: hash
{%-   if warden.cert.san %}
    - subjectAltName:  {{ warden.cert.san | json }}
{%-   else %}
    - subjectAltName:
      - dns: {{ warden.cert.cn or ([grains.fqdn] + grains.fqdns) | reject("==", "localhost.localdomain") | first | d(grains.id) }}
      - ip: {{ (grains.get("ip4_interfaces", {}).get("eth0", [""]) | first) or (grains.get("ipv4") | reject("==", "127.0.0.1") | first) }}
{%-   endif %}
    - CN: {{ warden.cert.cn or ([grains.fqdn] + grains.fqdns) | reject("==", "localhost.localdomain") | first | d(grains.id) }}
    - mode: '0640'
    - user: {{ warden.lookup.user.name }}
    - group: {{ warden.lookup.user.group }}
    - makedirs: true
    - append_certs: {{ warden.cert.intermediate | json }}
    - days_remaining: {{ warden.cert.days_remaining }}
    - days_valid: {{ warden.cert.days_valid }}
    - require:
      - sls: {{ sls_config_file }}
{%-   if not salt["file.file_exists"](warden.lookup.cert.privkey) %}
      - Vaultwarden certificate private key is managed
{%-   endif %}
{%- endif %}
