---
title: Deleting Multiple Builds in Copr
author: Dominik Tureček
layout: post
---

Previously, when you wanted to delete lots of build in the Copr, you had to do something like:

    for id in 10 12 13 15; do
        copr-cli delete-build $id
    done
    
This has been no problem for small projects. But it was a big issue for projects with thousands of packages (e.g., python rebuilds). After each `delete-build` we run `createrepo_c` to update repository. And for these big projects, it can run for several minutes. It can easily take a day to delete hundreds of builds this way.

Since the `copr-cli-1.87` (going to be released this week), you are now able to delete a group of builds specified by their IDs with a single command in the following style:

    copr-cli delete-build 10 12 13 15

This generates one action for the backend, deletes all the builds at once and it calls `createrepo_c` only once. This leads to a much shorter time needed for deleting larger numbers of builds.
