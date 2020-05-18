---
title: Deleting Multiple Builds in Copr
author: Dominik Tureček
layout: post
---

Since the latest release, we are now able to delete a group of builds specified by their IDs with a single command in the following style:

    copr-cli delete-build 10 12 13 15

Doing this, not only is it faster than deleting each build separately and waiting until it's done, but the whole deletion is handled as a single action on the backend, hopefully leading to a shorter time needed to delete larger numbers of builds.
