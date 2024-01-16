---
title: AI-driven Build Failure diagnosis
author: The Log Detective team
layout: post
---

We are delighted to introduce [Log Detective](https://log-detective.com/), an
exciting new project at the intersection of artificial intelligence and error
pattern detection in build logs. Unlike traditional approaches, *Log Detective*
relies on your valuable input to kickstart its journey.

What is Log Detective?
----------------------

Log Detective takes a new approach by seeking insights directly from
maintainers willing to help other fellow maintainers.  Instead of using
pre-trained generic models, we want to offer a customized AI system only on
sentences and language specific to packaging.  Provided by maintainers that are
able to identify and understand common error patterns in build logs.


What's Happening at Log Detective?
----------------------------------

**Data Collection Period**: We want to gather a rich dataset highlighting various
error patterns encountered in real-world (RPM and container first) build logs.

**Model Training Initiated**: With the collected data in hand, we'll train (or
complement/co-train) an error pattern detection model. This pivotal step marks a
significant leap towards *Log Detective's* goal of providing accurate and
efficient solutions. We plan to do this step once we gather more than 1000
samples.

**Integration with build-systems**: The API of the resulting system/model will
allow us later to integrate with Copr and other existing build systems to help
you "light-speed" diagnose errors in your future builds.

**Re-usability**: There will be tooling for using the models e.g. for analyzing
[Mock](https://github.com/rpm-software-management/mock) build logs locally.
This tooling would form a basic building block for the build system integration
above, trying to follow the UNIX principles.

**User Feedback Loop**: Your continued feedback and input will remain crucial.
We encourage you to stay engaged, share additional insights, and participate in
discussions to refine *Log Detective* further.


How Your Contributions Shape Log Detective?
-------------------------------------------

We prepared a [data-gathering portal](https://log-detective.com). The portal
contains a convenient form for you to easily describe the core of a given build
failure. The tool is integrated with the [Fedora Koji](https://koji.fedoraproject.org/koji/)
and [Fedora Copr](https://copr.fedorainfracloud.org/) build systems, but also
with [Packit service](https://packit.dev/), so it is sufficient to specify the
build/run ID for which you want to provide data and then, using the pre-uploaded
build logs, you can just "highlight" the important part of the build log, and
provide a human-readable description/reason for the build failure.


Join Us in Shaping the Future!
------------------------------

Visit our [GitHub
repository](https://github.com/fedora-copr/log-detective-website), and submit
your ideas and comments!

