---
title: Migrating Copr results to Pulp
author: Jakub Kadlčík
layout: post
---

Over the last year, the Copr team has put a lot of effort into supporting
[Pulp][pulp] as a storage for Copr build results. It is now time to realize the
investment.


## Status Quo

At this very moment, Copr hosts ~35k projects from ~8k Fedora users. The data
consumption sits around ~37TB with only ~3TB of free disk space. With a very few
exceptions, everything is stored in our "Copr backend" storage.

Our current storage is a RAID array of block devices with the Ext4
filesystem. For various reasons, AWS block devices larger than 16TB are either
hard to maintain or expensive. We plan to solve this problem by migrating to an
S3 object storage and Pulp, which is a mature solution for managing software
repositories.

We have already migrated all Copr team projects to Pulp to dogfood the
integration on ourselves, and we have already migrated [one large project][indi]
to avoid running out of disk space.


## The Goal

Our goal is to stop using the current "Copr backend" storage for all new
projects and migrate all existing project results to Pulp.


## Impact On Users

- No change to your workflows should be needed.
- Copr repositories enabled on user machines should continue working.
- While your projects are being migrated, all your builds and actions will be
  stuck in the "pending" state until the migration is finished.
- After the migration of your projects is finished, you shouldn't notice any
  difference from the status quo.
- For technical reasons, we won't notify users directly that their projects are
  about to be migrated. Please see the [Pulp Migration Schedule][schedule] to
  get a rough estimate of when you could be affected.
- Every user should be affected for at most 24 hours.

To summarize, the change should be transparent to you, there are no UI/UX
changes, and your builds may be paused while your project is being migrated.


## Our Plan

For a detailed, step-by-step plan with dates and tracked progress, please see
the [Pulp Migration Schedule][schedule]. Roughly, the plan is as follows:

1. Set the default storage for all new [Packit][packit] projects to Pulp.
2. Set the default storage for all new projects to Pulp.
3. Migrate large projects (17 projects that are 100GB+).
4. Migrate all projects with a few exceptions.
    - Migration will be done in alphabetical order by owner name.
    - Exceptions: Packit projects, [@rubygems/rubygems][rubygems],
    [@copr/PyPI][pypi], and [@copr/PyPI3][pypi3].
5. Migrate everything that remains.


## Contact

If you have any questions or worries regarding our migration of data to Pulp,
please let us know:

- [#buildsys:fedoraproject.org][matrix]
- [copr-devel mailing list][mailing-list]
- <https://github.com/fedora-copr/copr/discussions>



[schedule]: https://docs.google.com/spreadsheets/d/1VNhH10UbisuUvS4xaZGXGClpBhjYODpxEdsTC7p4vzk/
[pulp]: https://pulpproject.org/
[indi]: https://copr.fedorainfracloud.org/coprs/xsnrg/indi-3rdparty-bleeding/
[packit]: https://packit.dev/
[rubygems]: https://copr.fedorainfracloud.org/coprs/g/rubygems/rubygems/
[pypi]: https://copr.fedorainfracloud.org/coprs/g/copr/PyPI/
[pypi3]: https://copr.fedorainfracloud.org/coprs/g/copr/PyPI3/
[matrix]: https://matrix.to/#/#buildsys:fedoraproject.org
[mailing-list]: https://lists.fedoraproject.org/archives/list/copr-devel@lists.fedorahosted.org/
