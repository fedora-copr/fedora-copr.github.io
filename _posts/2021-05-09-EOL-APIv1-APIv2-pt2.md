---
title: EOL Copr APIv1 and APIv2, pt.2
author: Jakub Kadlčík
layout: post
---

During the last year, we are incrementally dropping support for Copr's
APIv1 and APIv2. We kindly ask you to migrate to [APIv3][apiv3]. Some
reasoning and our motivation for doing so can be found the
[Copr has a brand new API][new-api-blog-post] blog post.

According to the [deprecation schedule][deprecation-schedule], we just
took the following step:

> * April 2021 - print warning on STDERR when you use APIv2 from
>   python3-copr and remove APIv1 from python3-copr library

That means that if you cannot migrate to APIv3 yet, you can still send
requests to APIv1 endpoints directly, without using the `python3-copr`
library, or you can temporarily freeze on
[python-copr-1.109][python-copr] and [copr-cli-1.93][copr-cli].

Please don't put aside the migration of your code for much longer. In
September the APIv1 is going to be dropped from the frontend and APIv2
from clients.


[apiv3]: https://python-copr.readthedocs.io/en/latest/ClientV3.html
[new-api-blog-post]: http://frostyx.cz/posts/copr-has-a-brand-new-api
[deprecation-schedule]: https://fedora-copr.github.io/posts/EOL-APIv1-APIv2
[python-copr]: https://koji.fedoraproject.org/koji/buildinfo?buildID=1724184
[copr-cli]: https://koji.fedoraproject.org/koji/buildinfo?buildID=1724194
