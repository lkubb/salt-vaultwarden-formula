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



``warden.web_vault``
^^^^^^^^^^^^^^^^^^^^



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



``warden.web_vault.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^



