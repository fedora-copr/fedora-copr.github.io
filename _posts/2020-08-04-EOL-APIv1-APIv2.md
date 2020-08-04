---
title: EOL Copr APIv1 and APIv2
author: Miroslav Suchý
layout: post
---
During Copr history, we got [three APIs](http://frostyx.cz/posts/copr-has-a-brand-new-api). For a long time, we maintained all versions.

We decided that it is time to remove the old versions. We are going to start with APiv1.  

The schedule is:

  * September 2020 - print warning on STDERR when you use APIv1 from python3-copr.
  * April 2021 - print warning on STDERR when you use APIv2 from python3-copr and remove APIv1 from python3-copr library
  * September 2021 - remove APIv1 code from the frontend. I.e., Copr service will not understand APIv1 calls. Remove APIv2 from python3-copr library.
  * April 2022 - remove APIv2 code from the frontend. I.e., Copr service will not understand APIv2 calls.

I strongly encourage you to [migrate](https://python-copr.readthedocs.io/en/latest/client_v3/migration.html#migration) your scripts to [APIv3](https://python-copr.readthedocs.io/en/latest/ClientV3.html).
