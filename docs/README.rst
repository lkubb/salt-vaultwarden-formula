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

Manage Vaultwarden inofficial Bitwarden server with Salt.

This is currently written for Debian-based systems only, although extending the formula should be easy.

Mind that the tests are currently just for show and have not been implemented.

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
* This compiles from source. You can specify any valid git rev as ``version``, or keep ``latest``. The latter will result in a query to Github releases.
* Since this formula compiles from source, a functional Rust toolchain is needed on the system. This can either be provided beforehand, by a separate formula or with the inbuilt state. Set ``rust_setup: false`` to disable any action, to the ID of an sls file to include + require it or to ``true`` to enable the inbuilt mechanism.
* The web vault is downloaded from the patched official release. Set the web vault version to ``false`` to disable installation.
* You can modify the paths found in ``lookup:paths``. If they are different than default, ``post-map.jinja`` will automatically adjust the configuration, so you can focus on the rest.

Configuration
-------------
An example pillar is provided, please see `pillar.example`. Note that you do not need to specify everything by pillar. Often, it's much easier and less resource-heavy to use the ``parameters/<grain>/<value>.yaml`` files for non-sensitive settings. The underlying logic is explained in `map.jinja`.

Available states
----------------

.. contents::
   :local:

``warden``
^^^^^^^^^^

*Meta-state (This is a state that includes other states)*.

This installs the vaultwarden package,
manages the vaultwarden configuration file and then
starts the associated vaultwarden service.

``warden.package``
^^^^^^^^^^^^^^^^^^

This state will install vaultwarden only.

``warden.config``
^^^^^^^^^^^^^^^^^

This state will configure the vaultwarden service and has a dependency on ``warden.package.install``
via include list.

``warden.service``
^^^^^^^^^^^^^^^^^^

This state will start the warden service and has a dependency on ``warden.config``
via include list.

``warden.clean``
^^^^^^^^^^^^^^^^

*Meta-state (This is a state that includes other states)*.

This state will undo everything performed in the ``warden`` meta-state in reverse order, i.e.
stops the service,
removes the configuration file and
then uninstalls the package.

``warden.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^

This state will stop the warden service and disable it at boot time.

``warden.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^

This state will remove the configuration of the warden service and has a
dependency on ``warden.service.clean`` via include list.

``warden.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^

This state will remove the warden package and has a depency on
``warden.config.clean`` via include list.

``warden.web_vault``
^^^^^^^^^^^^^^^^^^^^

*Meta-state (This is a state that includes other states)*.

This state installs the web vault before
configuring and starting the warden service.

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
