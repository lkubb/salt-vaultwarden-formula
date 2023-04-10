# vim: ft=sls

{#-
    Starts the warden service and enables it at boot time.
    Has a dependency on `warden.config`_.
#}

include:
  - .running
