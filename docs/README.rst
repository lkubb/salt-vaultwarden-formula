.. _readme:

Vaultwarden Formula
===================

|img_sr| |img_pc|

.. |img_sr| image:: https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg
   :alt: Semantic Release
   :scale: 100%
   :target: https://github.com/semantic-release/semantic-release
.. |img_pc| image:: https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white
   :alt: pre-commit
   :scale: 100%
   :target: https://github.com/pre-commit/pre-commit

Manage Vaultwarden inofficial Bitwarden server with Salt. This formula can compile the binary from source or pull a prebuilt binary\* and manage the service and configuration.

Installing and configuring a `reverse proxy <https://github.com/dani-garcia/vaultwarden/wiki/Proxy-examples>`_, `fail2ban <https://github.com/dani-garcia/vaultwarden/wiki/Fail2Ban-Setup>`_ and possibly `log shipping <https://selivan.github.io/2017/02/07/rsyslog-log-forward-save-filename-handle-multi-line-failover.html>`_ (if you run those on another system) are out of scope for this formula. For hints, see `the official docs <https://github.com/dani-garcia/vaultwarden/wiki>`_. I wrote formulae for Rsyslog and Fail2Ban to take care of the latter two. For an example configuration, see :ref:`integration`.

This was written for Debian and RHEL OS families primarily, although adapting the formula should be relatively easy.

Mind that the tests are currently just for show and have not been implemented.

\* *There is no official one.*

.. contents:: **Table of Contents**
   :depth: 1

General notes
-------------

See the full `SaltStack Formulas installation and usage instructions
<https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

If you are interested in writing or contributing to formulas, please pay attention to the `Writing Formula Section
<https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#writing-formulas>`_.

If you want to use this formula, please pay attention to the ``FORMULA`` file and/or ``git tag``,
which contains the currently released version. This formula is versioned according to `Semantic Versioning <http://semver.org/>`_.

See `Formula Versioning Section <https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#versioning>`_ for more details.

If you need (non-default) configuration, please refer to:

- `how to configure the formula with map.jinja <map.jinja.rst>`_
- the ``pillar.example`` file
- the `Special notes`_ section

Special notes
-------------
* This can compile from source. You can specify any valid git rev as ``version``, or keep ``latest``. The latter will result in a query to Github releases.
* For compilation, a functional Rust toolchain is required on the system. This can either be provided beforehand, by a separate formula or with the inbuilt state. Set ``rust_setup: false`` to disable any action, to the ID of an sls file to include + require it or to ``true`` to enable the inbuilt mechanism.
* The Web Vault is downloaded from the patched official release (including verifying the signature). Set the web vault version to ``false`` to disable installation.
* You can modify the paths found in ``lookup:paths``. If they are different than default, ``post-map.jinja`` will automatically adjust the configuration, so you can focus on the rest.

Configuration
-------------
An example pillar is provided, please see `pillar.example`. Note that you do not need to specify everything by pillar. Often, it's much easier and less resource-heavy to use the ``parameters/<grain>/<value>.yaml`` files for non-sensitive settings. The underlying logic is explained in `map.jinja`.


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


``warden.cert``
^^^^^^^^^^^^^^^
Generates a TLS certificate + key for Vaultwarden.
Depends on `warden.config`_.


``warden.web_vault``
^^^^^^^^^^^^^^^^^^^^
Installs the web vault from Github releases (by default).
Checks signatures before extracting.


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
Has a dependency on `warden.config.clean`_.


``warden.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^
Removes the configuration of the warden service and has a
dependency on `warden.service.clean`_.


``warden.cert.clean``
^^^^^^^^^^^^^^^^^^^^^
Removes generated Vaultwarden TLS certificate + key.
Depends on `warden.service.clean`_.


``warden.web_vault.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the Web vault.


``warden.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^
Stops the warden service and disables it at boot time.


``warden.rust.clean``
^^^^^^^^^^^^^^^^^^^^^
Uninstalls the Rust toolchain.



Contributing to this repo
-------------------------

Commit messages
^^^^^^^^^^^^^^^

**Commit message formatting is significant!**

Please see `How to contribute <https://github.com/saltstack-formulas/.github/blob/master/CONTRIBUTING.rst>`_ for more details.

pre-commit
^^^^^^^^^^

`pre-commit <https://pre-commit.com/>`_ is configured for this formula, which you may optionally use to ease the steps involved in submitting your changes.
First install  the ``pre-commit`` package manager using the appropriate `method <https://pre-commit.com/#installation>`_, then run ``bin/install-hooks`` and
now ``pre-commit`` will run automatically on each ``git commit``. ::

  $ bin/install-hooks
  pre-commit installed at .git/hooks/pre-commit
  pre-commit installed at .git/hooks/commit-msg

State documentation
~~~~~~~~~~~~~~~~~~~
There is a script that semi-autodocuments available states: ``bin/slsdoc``.

If a ``.sls`` file begins with a Jinja comment, it will dump that into the docs. It can be configured differently depending on the formula. See the script source code for details currently.

This means if you feel a state should be documented, make sure to write a comment explaining it.

Testing
-------

Linux testing is done with ``kitchen-salt``.

Requirements
^^^^^^^^^^^^

* Ruby
* Docker

.. code-block:: bash

   $ gem install bundler
   $ bundle install
   $ bin/kitchen test [platform]

Where ``[platform]`` is the platform name defined in ``kitchen.yml``,
e.g. ``debian-9-2019-2-py3``.

``bin/kitchen converge``
^^^^^^^^^^^^^^^^^^^^^^^^

Creates the docker instance and runs the ``warden`` main state, ready for testing.

``bin/kitchen verify``
^^^^^^^^^^^^^^^^^^^^^^

Runs the ``inspec`` tests on the actual instance.

``bin/kitchen destroy``
^^^^^^^^^^^^^^^^^^^^^^^

Removes the docker instance.

``bin/kitchen test``
^^^^^^^^^^^^^^^^^^^^

Runs all of the stages above in one go: i.e. ``destroy`` + ``converge`` + ``verify`` + ``destroy``.

``bin/kitchen login``
^^^^^^^^^^^^^^^^^^^^^

Gives you SSH access to the instance for manual testing.
