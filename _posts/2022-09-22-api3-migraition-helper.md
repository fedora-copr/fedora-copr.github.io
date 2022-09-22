---
title: Migrate to APIv3 queries
author: Pavel Raiskup
layout: post
---

We had planned the APIv2 drop [for a very long time][api_schedule], and we
started with that quite some time ago (`api_2` dropped from our Python API lib).
The team was so much familiar with this ongoing change, and was kind of bored
from announcements so we forgot about analyzing the ongoing `api_2` Apache
`access_log` entries.

The change has [already happened][release_notes], `api_2` is gone.  So here
comes at least a small helper post that should make the migration from `api_2`
to `api_3` trivial.  Only the routes that are being accessed (and are 404) are
covered here.

Also, it might be a good idea to use the Python API (`python3-copr`) if
possible.

How to get a build info
-----------------------

- `Old route: /api_2/builds/<ID>`
- `New route: /api_3/build/<ID>`

This should be easy as it looks.  But note that newly you want look at the
`.projectname` and `.ownername` fields in the output because you'll need them in
the other routes.


How to get a project info
-------------------------

- `Old route: /api_2/projects/<project_id>`
- `New route: /api_3/project?ownername=<ownername>&projectname=<projectname>`


Listing builds in a project
---------------------------

- `Old route: /api_2/builds?project_id=<proj_id>`
- `New route: /api_3/build/list/?ownername=<ownername>&projectname=<projectname>`

We no longer work with project IDs here.

Note the needed trailing slash symbol after `list/?...`, this is a bug and
should be fixed so both `list?` and `list/?` variants are possible in the
future.


Last build in a project
-----------------------

Same as the previous one, just add the `&limit=N` argument:

- `Old route: /api_2/builds?project_id=<proj_id>&limit=<N>`
- `New route: /api_3/build/list/?ownername=<ownername>&projectname=<projectname>&limit=<N>`


List of owner's projects
------------------------

- `Old route: /api_2/projects?owner=<owner>&name=<owner>`
- `New route: /api_3/project?ownername=<owner>&projectname=<projectname>`


Build config
------------

This was never considered a kind of "API" info - but rather internal thing.  It
lived in the `api_2` namespace mistakenly.  The info is now moved to the
`/backend` namespace ("internals").  If you are the user, please let the team
know about your use-case so we can help you:

- `Old route: /api_2/build_tasks/<build_id>/<chroot_name>`
- `New route: /backend/get-build-task/<build-id>-<chroot_name>`

[api_schedule]: https://fedora-copr.github.io/posts/EOL-APIv1-APIv2
[release_notes]: https://docs.pagure.org/copr.copr/release-notes/2022-09-21.html
