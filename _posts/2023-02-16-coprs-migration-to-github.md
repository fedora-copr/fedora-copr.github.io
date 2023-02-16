---
title: Copr's migration to GitHub
author: Jiří Kyjovský
layout: post
---

For a very long time, Copr mainliners have been considering migrating from
Pagure to GitHub. The problem has been the constant problems with Pagure
and even though GitHub is not open source, it just works. Not
to mention that GitHub is miles ahead of Pagure with plenty of useful
features.

So on the migration itself, Copr had a mirror on GitHub at the time, so
the code migration wasn't a problem. The problem was migrating all the issues
and pull requests so that their IDs were preserved. We wanted to keep the
same IDs for compatibility with the links in the commits. And there
is no general solution to migrate all issues and PRs from Pagure to GitHub
while preserving the IDs. So that's why I wrote a temporary
[script](https://github.com/nikromen/copr-gh-migration/blob/main/script.py)
to migrate Copr. Please note that the code was only meant to be used once
and only for the Copr migration, so it should not be used by anyone.
However, it can serve as an inspiration
and I would also like to share with you some of the problems I encountered
during the migration.


## Choose the right tools

For the whole migration, I used the tool [ogr](https://github.com/packit/ogr),
which provides a unified API for communicating with GitHub, Gitlab, and Pagure.
For communication with the GitHub API, you need to set up a
[GitHub token](https://github.com/settings/tokens), and likewise for
[Pagure](https://pagure.io/settings#nav-api-tab). Note the permissions that
you give the token, only give it as much as you really need (for example, you
probably don't want to allow it to delete the repository).

And then you just have to start using the tokens

```py
gh_service = GithubService(token=GITHUB_TOKEN)
pagure_service = PagureService(token=PAGURE_TOKEN, instance_url="https://pagure.io")

gh_copr_project = gh_service.get_project(namespace="fedora-copr", repo="copr")
pagure_copr_project = pagure_service.get_project(namespace="copr", repo="copr", username="pagure_nick")
```


## What to migrate

First of all, it is important to determine what we want to migrate.
In our case, we wanted to migrate as quickly as possible, so we just needed
to migrate all issues and PRs to keep the order of their IDs. To
save time, decided to migrate the PRs as issues while migrating only
the issues content. For PRs, we put a link to the original PR in Pagure.

In case of private issues, or deleted PRs or issues, there will be gaps
between the IDs. We have decided to fill these gaps only with empty issues.


### Pull Requests migration

But if someone wants to migrate PRs, yes it can be done, it's just a bit
tricky. To migrate PRs with their diff, you need to pull the
last commit from Pagure before the pull request and the last commit of
the pull request. This would be something like this:

```shell
# you are in a main branch
git switch -c pr-branch
git reset --hard the-last-commit-of-pr
git switch -c main-before-pr
git reset --hard the-last-commit-before-pr
# do your changes in <pr-branch>
git push <remote> <pr-branch>:<main-before-pr>
```

This pushes all changes to the `main-before-pr` branch, which you can create
PR in GitHub (or via GitHub API) and then merge PR and delete the branch
immediately. The PR history will remain.


## Rate limits

Then GitHub stabbed me in the back with its crazy
[limits](https://docs.github.com/en/rest/overview/resources-in-the-rest-api?apiVersion=2022-11-28#secondary-rate-limits).
According to their
[instructions](https://docs.github.com/en/rest/guides/best-practices-for-integrators?apiVersion=2022-11-28#dealing-with-secondary-rate-limits),
I did the `sleep(1)` between POST requests, but after about 40 requests I
always hit the limit anyway, and for this case in there is no `Retry-After`
parameter in the header. With each subsequent hit of the limit, there was a
longer and longer punishment, even tens of minutes. At this point, I gave up
and just put sleep for 2 minutes between each POST request. Also, I shrunk
the issue content just to one long message so that it was just one POST
request [example](https://github.com/fedora-copr/copr/issues/2001).
So we'll be migrating for 4 days...

Maybe I could get around these limits by running the script as a GitHub
Action, on which there are other limit rules, but I didn't want to
waste my time with that.


## The migration process itself

The migration itself wasn't that complicated - from a code point of view.

- I created API keys for Pagure and GitHub

- Downloaded the Pagure data into a JSON file for good measure
(so that nothing would change during the long 4-day migration)
[source](https://github.com/nikromen/copr-gh-migration/blob/50754dc1b97b3e0505638ec2aec84f20e6ecd539/script.py#L112)
    
    - Then just convert the data back from the JSON file:

    ```py
    pagure_prs = {
        pr.id: pr
        for pr in [
            ogr.services.pagure.PagurePullRequest(pr_dict, self.pagure_project)
            for pr_dict in pagure_prs_json
        ]
    }
    ```

- Incremental migration of Copr

    - First I migrated without any content.
    [script at that time](https://github.com/nikromen/copr-gh-migration/blob/50754dc1b97b3e0505638ec2aec84f20e6ecd539/script.py)

    - Then I migrated the labels.
    [script at that time](https://github.com/nikromen/copr-gh-migration/blob/7a08cb0332de8d189624305ea30740d4dbf57e8a/script.py)

    - After a couple of weeks, I migrated the issue's content as well (that's
    why the code isn't logically coherent).
    [script at that time](https://github.com/nikromen/copr-gh-migration/blob/aeec2ab668ace02c75188a36cec102aedad0eced/script.py)

- On Pagure in
[Project Options](https://pagure.io/my-playground/settings#projectoptions-tab)
we set the issue tracker to read-only.


## Conclusion

I recommend using ogr for migration, it saved me some nerves due to the fact
that it wraps Pagure API in Python and it also provides functionality to
migrate data from Pagure to GitHub. It just requires a lot of patience,
because of the very strict limits on the GitHub side, but if you download the
data from Pagure before the migration it can run for a really long time
without consequences.
