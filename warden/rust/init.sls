# vim: ft=sls

{#-
    Installs rustup-init and Rust nightly in order to compile vaultwarden.

    Warning:
      The rustup-init installation pipes the output of ``warden.lookup.rustup_init.source``
      into a shell of the build user. The file hash is verified against ``warden.lookup.rustup_init.source_hash``.
      You can override the URL in ``warden.lookup.rustup_init.source`` for a local source.
#}

include:
  - .install
