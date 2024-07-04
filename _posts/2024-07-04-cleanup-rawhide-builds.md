---
title: Rawhide (aka "rolling") chroot EOL policy in Copr
author: Pavel Raiskup
layout: post
---

In Fedora Copr, we strive to avoid wasting disk storage unnecessarily.  Disk
storage is the commodity that incurs the highest cloud costs.  For example, we
clean the build results for EOL chroots, we clean source builds (build results
that are imported into DistGit), we clean the DistGit lookaside cache, build
logs, uploaded files, failed build logs, and more.  Yet, we maintain >= 40TB of
data with RAID redundancy, volume snapshots, ...

[Most of the Fedora Copr backend
storage](https://copr-be.cloud.fedoraproject.org/stats/distro.html) is used for
holding the build results related to Fedora, with the largest consumer being the
Fedora Rawhide chroot.

The "problem" with Fedora Rawhide as a "rolling" distribution is that it never
reaches EOL, unlike branched Fedora releases.  For example, take a look at the
data consumption for the old Fedora 35 in the previous link if you want to see
the difference.

Yet, _most_ existing projects _do_ build for Rawhide -- and until now, we did
not have a tool for performing any cleanups there.  Now we do.

**Warning**: **Fedora Rawhide** is not the only target distro suffering from
this problem. There are other rolling distros we build for, where we'll apply
the same policy, namely **Fedora ELN**, **openSUSE Tumbleweed**, and **Mageia
Cauldron**.

## The Rolling Policy Being Implemented

In [this Copr issue](https://copr-be.cloud.fedoraproject.org/stats/distro.html),
we concluded that a viable option is to detect the liveness of particular
"rolling" chroots in Copr projects. If a chroot appears
lifeless/dead, we will disable it and schedule it for future removal.  According
to the initial proposed policy, Copr will mark a chroot as "lifeless" after a
6-month period of build inactivity. Such a "lifeless" chroot then enters another
6-month protection period where we keep the built results, but the corresponding
project administrators are informed about the future chroot data removal.  If the
chroot remains inactive during this period, the data will be removed.  The
cleanup process is extended if the chroot appears active, either by (a) a user
building a package in the chroot or (b) a user manually [prolonging the chroot
validity](https://copr.fedorainfracloud.org/user/repositories/).

At the time of this announcement, there is no risk of data loss.  The
corresponding code is not yet deployed in production, and once it is, it will
take at least 12 months before we remove any data.  We just want to inform you
and prepare you to take action.

The default limits (6+6 months) are chosen because Fedora’s default release
cycle is about 6 months.  During this time, something significant typically
happens that makes the built packages somewhat useless or non-installable
(e.g., library API changes, changes in generated `Provides`, anything that makes
the package non-installable or non-working).  However, we understand that some
packages (e.g., data-only packages) could remain working for years without
needing a rebuild.  If this applies to you, try to estimate how much
inconvenience this change brings (the "manual chroot prolonging"), and let us
know.
