.. _integration:

Further integrations
====================

Fail2ban
--------
It is advised to harden your Vaultwarden service at least against simple brute force attacks. `This can be achieved with fail2ban <https://github.com/dani-garcia/vaultwarden/wiki/Fail2Ban-Setup>`_.

I wrote a formula that can be used to `manage fail2ban <https://github.com/lkubb/salt-fail2ban-formula>`_ (the one from `saltstack-formulas <https://github.com/saltstack-formulas/fail2ban-formula>`_ does not seem to support libmapstack atm). Here is an example configuration for my formula that translates the official Vaultwarden example setup:

.. code-block:: yaml

  # vim: ft=yaml
  ---
  values:
    jails_enabled:
      - vaultwarden
      - vaultwarden-admin
    jails:
      vaultwarden:
        port: [80, 443, 8081]
        filter: vaultwarden
        action: '%(banaction_allports)s'
        logpath: /var/log/vaultwarden/vaultwarden.log
        maxretry: 5
        bantime: 14400
        findtime: 14400
      vaultwarden-admin:
        port: [80, 443]
        filter: vaultwarden-admin
        action: '%(banaction_allports)s'
        logpath: /var/log/vaultwarden/vaultwarden.log
        maxretry: 5
        bantime: 14400
        findtime: 14400
    filters:
      vaultwarden:
        INCLUDES:
          before: common.conf
        Definition:
          failregex: '^.*Username or password is incorrect\. Try again\. IP: <HOST>\. Username:.*$'
          ignoreregex: ''
      vaultwarden-admin:
        INCLUDES:
          before: common.conf
        Definition:
          failregex: '^.*Invalid admin token\. IP: <HOST>.*$'
          ignoreregex: ''
  ...

Log shipping
------------
When running a reverse proxy on a different system in front of Vaultwarden, Fail2Ban needs to be run there as well. It needs access to the Vaultwarden logs though, so sending them becomes necessary. This is where Rsyslog can be used. Mind that the reverse proxy must include the real client IP in the headers of the proxied request for this to work as intended. Here is an example configuration that implements this with my `Rsyslog formula <https://github.com/lkubb/salt-rsyslog-formula>`_:

Client:
~~~~~~~
This is for the system running Vaultwarden.

.. code-block:: yaml

  # vim: ft=yaml
  ---
  values:
    custom:
      40-vaultwarden:
        modules:
          imfile: {}
        inputs:
          imfile:
            - file: /var/log/vaultwarden/vaultwarden.log
              tag: vaultwarden
              severity: info
              ruleset: send_remote
        rulesets:
          send_remote:
            content: |
              action(type="omfwd" target="{{ reverse_proxy_ip }}" port="514" protocol="tcp")
  ...

Server:
~~~~~~~
This is for the system running the reverse proxy:

.. code-block:: yaml

  # vim: ft=yaml
  ---
  values:
    server:
      enabled: true
      modules:
        imtcp: {}
      inputs:
        imtcp:
          - port: 514
            name: remote_logs
            ruleset: remote_logs
      rulesets:
        remote_logs:
          parameters: {}
          content: |
            action(type="omfile" dynaFile="remote_logs")
      templates:
        remote_logs:
          type: string
          value: /var/log/%hostname%/%programname%.log
  ...
