---
title: "Reviewing annotations in Log Detective"
author: "Tomas Tomecek"
layout: "post"
---

You may have heard of our [Log Detective](https://logdetective.com/) project.
We want to use AI to process your logs of failed builds. The tool tells you
where the problem is and how to fix it: you can try this today locally on your
laptop using the [logdetective CLI
tool](https://github.com/fedora-copr/logdetective). In order to provide the
best answers in the future, we need to collect annotations of specific failures
for what went wrong and how to fix it.

We appreciate everyone who submitted annotations already, thank you! It will
allow us to create a model with knowledge about building software, not just
RPMs, but also container images, test failures and various language specific
buildsystems. I envision that Log Detective will provide useful answers to most
of logs with build failures. Though we still have a long way getting there.

So far, the annotations on the [logdetective.com](https://logdetective.com/)
site are read-only. Once submitted, there is no way to change them. Everyone
can download them, but that's it.

Starting in August 2024, we have now deployed a review interface on the Log
Detective website. This will allow anyone to rate (thumbs up and down) each
snippet and therefore curate collected data.

![](/assets/img/posts/logdetective-with-review.png)

Annotations combined with your rating will enable us create a high-quality data
set and increase Log Detective's chance giving you solid advice.

We've already done research on how to utilize this data inside Log Detective but
haven't decided yet. Please stay tuned.

![](/assets/img/posts/logdetective-review-submit.png)

## How do I review snippets?

Once you click the "Review logs" button at the top menu, you'll reach the new
review interface. The instructions are on the left side.

![](/assets/img/posts/logdetective-review-instructions.png)

You are welcome to add more snippets if you can spot more information that
should be annotated. If an annotation is incorrect:
1. You are welcome to edit the text and provide correct explanation
2. If the highlight is wrong, please downvote it and create a new annotation.
