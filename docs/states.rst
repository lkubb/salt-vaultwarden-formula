Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``warden``
^^^^^^^^^^
*Meta-state*.

This installs the warden package,
manages the warden configuration file
and then starts the associated warden service.


``warden.package``
^^^^^^^^^^^^^^^^^^
Installs the warden package only.


``warden.config``
^^^^^^^^^^^^^^^^^
Manages the warden service configuration.
Has a dependency on `warden.package`_.


``warden.service``
^^^^^^^^^^^^^^^^^^
Starts the warden service and enables it at boot time.
Has a dependency on `warden.config`_.


``warden.rust``
^^^^^^^^^^^^^^^
Installs rustup-init and Rust nightly in order to compile vaultwarden.

Warning:
  The rustup-init installation pipes the output of ``warden.lookup.rustup_init.source``
  into a shell of the build user. The file hash is verified against ``warden.lookup.rustup_init.source_hash``.
  You can override the URL in ``warden.lookup.rustup_init.source`` for a local source.


``warden.web_vault``
^^^^^^^^^^^^^^^^^^^^
Installs the web vault from Github releases (by default).
Checks signatures before extracting.


``warden.clean``
^^^^^^^^^^^^^^^^
*Meta-state*.

Undoes everything performed in the ``warden`` meta-state
in reverse order, i.e.
stops the service,
removes the configuration file and then
uninstalls the package.


``warden.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^
Removes the warden package.
Has a depency on `warden.config.clean`_.


``warden.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^
Removes the configuration of the warden service and has a
dependency on `warden.service.clean`_.


``warden.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^
Stops the warden service and disables it at boot time.


``warden.rust.clean``
^^^^^^^^^^^^^^^^^^^^^
Uninstalls the Rust toolchain.


``warden.web_vault.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the Web vault.


