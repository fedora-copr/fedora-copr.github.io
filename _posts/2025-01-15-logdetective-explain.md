---
title: "Log Detective can now explain build log failures"
author: "Tomas Tomecek"
layout: "post"
---

We're thrilled to announce new functionality of [Log
Detective](https://logdetective.com/). The service can now explain in detail a
build log of your choice. Click on
[logdetective.com/explain](https://logdetective.com/explain), paste a
link to your log, wait one minute and you should see description of important
lines with the overall explanation.


## Disclaimer

This is our initial prototype of this functionality. We appreciate all your
feedback. Please, be patient as there will be service disruptions, instability
and usability issues.

* **1️⃣ The service can process only one request at a time.** We understand this
is very limitng, especially when multiple people will use the service at the
same time. You may need to wait several minutes to get a reply in such a case.
We are thankful to the Fedora Project for sponsoring our infrastructure needs,
but in order to reach the scale of popular AI services, we would need much more
GPU compute.

* **🌍 We are using a general-purpose LLM in the background.** The data we are
collecting are not being utilized just yet in the answers. We still don't have
enough data to fine-tune a model that would provide high-quality answers. Our
goal for 2025 is to research and train such model.

* **🔬 The functionality is highly experimental.** Our team has worked diligently
to deliver this prototype. However, we recognize that this represents only a
fraction of the service's full potential. We eagerly welcome all feedback and
would greatly appreciate it if you could report any unusual behavior, errors,
or tracebacks that you encounter.

## Step by step guide

The new functionality is available under "Explain logs".

[https://logdetective.com/explain](https://logdetective.com/explain)

![](/assets/img/posts/logdetective-explain.png)

The service only accepts links to raw logs: all of these are always available
for Copr and Koji builds.

![](/assets/img/posts/logdetective-explain-with-link.png)

Upon submission, Log Detective retrieves the log file and initiates the
processing phase. During this process, the service interacts with the
underlying LLM through multiple requests. It usually takes one minute to return
an answer.

![](/assets/img/posts/logdetective-explain-result.png)

The result is split into two sections:

* The left side contains overall explanation for the whole log.

* Log Detective uses [Drain](https://github.com/logpai/Drain3) to select
  important lines from the log. You can see descriptions of them on the right
  side after you expand them by clicking on a line.

In our example here, we can see the build failed because a required library
`libtree-sitter.so.0.23()(64bit)` is not available and cannot be installed. Log
Detective does a decent attempt explaining this issue though it fails with the
solution: it's not as easy as just installing the library with `dnf`. There is
definitely a room for improvement in the final answer.

This is where you can help. If you are not satisfied with the answer and know a
better one, head over to Log Detective website homepage, enter the log link and
annotate it for us. Once we fine-tune our own model, the service can provide
much better explanations thanks to you.

You can reach us at the Fedora Copr build tools discussion Matrix channel: `#buildsys:fedoraproject.org`.
Please open issues in: [github.com/fedora-copr/logdetective-website/issues/new/choose](https://github.com/fedora-copr/logdetective-website/issues/new/choose)
