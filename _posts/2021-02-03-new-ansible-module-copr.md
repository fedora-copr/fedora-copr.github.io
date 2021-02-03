---
title: New Ansible module Copr
author: Silvie Chlupova
layout: post
---

We created a new Ansible module for Copr, which was added to the [community general collection](https://github.com/ansible-collections/community.general/releases/tag/2.0.0) in [Ansible galaxy](https://galaxy.ansible.com/community/general) during the release of the latest version 2.0.0. The module code can be found in the GitHub repository of the mentioned [collection](https://github.com/ansible-collections/community.general/blob/2.0.0/plugins/modules/packaging/os/copr.py).

## Synopsis

This module can enable, disable or remove the specified repository.

## Quick setup

To install a collection hosted in Galaxy:

    ansible-galaxy collection install community.general

You can also install the `ansible-collection-community-general` package with our module as soon as the Fedora package version is updated to version 2.0 (currently available version is 1.0):

    dnf install ansible-collection-community-general

Or you can use the tarball (version 2.0.0):

    ansible-galaxy collection install https://github.com/ansible-collections/community.general/archive/2.0.0.tar.gz -p ./collections

## Module usage

To use it in a playbook, specify: `community.general.copr`.

### Examples of use in a playbook 

Use state `enabled` to enable the Copr project, then use the name of the user/project and the chroot you wish to enable. 

    - name: Enable project Test of the user schlupov
      community.general.copr:
        host: copr.fedorainfracloud.org
        state: enabled
        name: schlupov/Test
        chroot: fedora-31-x86_64

Use state `absent` to remove the Copr project. The host is optional and copr.fedorainfracloud.org is used as the default. Likewise, chroot is not required, so if you use the module on fedora 32 and the x86_64 architecture, fedora-32-x86_64 will be used as chroot option.

    - name: Remove project copr of the group copr
      community.general.copr:
        state: absent
        name: @copr/copr

Use state `disabled` to disable the Copr project. The repository can be seen in the /etc/yum.repos.d/ directory, but is set to disabled. On the other hand, in case of state absent, the repo file is completely removed from the system.

    - name: Disable project copr of the group copr
      community.general.copr:
        state: disabled
        name: @copr/copr
        chroot: fedora-32-x86_64

## Parameters

| Parameter |  Choices/Defaults                                            | Comments                                                                                                                                                                                                                                    | Required |
|-----------|--------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| host      | Default: "copr.fedorainfracloud.org"                         | The Copr host to work with                                                                                                                                                                                                                  | No       |
| protocol  | Default: "https"                                             | This indicate which protocol to use with the host                                                                                                                                                                                           | No       |
| name      |                                                              | Copr project name, for example @copr/copr-dev                                                                                                                                                                                             | Yes      |
| state     | Default: "enabled", Choices: "enabled", "disabled", "absent" | Whether to set this project as enabled, disabled or absent                                                                                                                                                                                  | No       |
| chroot    | Default: your "os-os_version-architecture"                        | The name of the chroot that you want to enable/disable/remove in the project, for example epel-7-x86_64. Default chroot is determined by the operating system, version of the operating system, and architecture on which the module is run | No       |

