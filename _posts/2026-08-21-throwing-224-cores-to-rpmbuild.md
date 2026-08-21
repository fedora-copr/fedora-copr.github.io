---
title: Throwing 224 Cores at rpmbuild
author: Miroslav Suchý
layout: post
---

In Fedora Copr, we maintain a special tier of build machines known as [High-Performance Builders](https://docs.copr.fedorainfracloud.org/user_documentation/powerful_builders.html#high-performance-builders) (or as we call them internally, "powerful builders"). 

Historically, gaining access to these machines required some manual intervention. Maintainers had to write to us, and we would enable them for specific projects or packages based on matching regular expressions. I’m happy to say those days of manual labor are over. This process is now entirely automated thanks to [rpmeta](https://github.com/fedora-copr/rpmeta) (expect a dedicated blog post on this soon).

To give you an idea of the hardware: our standard builder in AWS EC2 is a [`c7i.xlarge`](https://instances.vantage.sh/aws/ec2/c7i.xlarge?currency=USD), providing a respectable 4 vCPU and 8 GB of RAM. The high-performance x86_64 counterpart is the [`c7a.8xlarge`](https://instances.vantage.sh/aws/ec2/c7a.8xlarge?currency=USD) flavor, boasting 32 vCPU and 64 GB of RAM. The real-world impact? Massive packages that typically churned for 23 hours on a standard instance are now finishing in 5 to 6 hours.

But this got me thinking. Is it possible to go even further? How much does throwing progressively heavier hardware at the problem actually accelerate an RPM build? 

## Enter the Megabuilder

To test the absolute extremes, I decided to fire up the most powerful EC2 instance I could find. Finding an available datacenter for these behemoths was a challenge in itself, but I eventually managed to spin up a [`u-3tb1.56xlarge`](https://instances.vantage.sh/aws/ec2/u-3tb1.56xlarge?currency=USD) - the third biggest flavor in AWS EC2.

Let’s call it the **Megabuilder**. It packs **224 vCPUs and 3 TB of RAM**. 

To ensure disk I/O wouldn't skew the results, all test builds were executed with Mock's `tmpfs` plugin enabled. The entire build process happened purely in RAM, making disk speed irrelevant. 

Here is what happened when I fed it some of Fedora's most notoriously heavy packages.

### Test 1: `python3-torch` (The Socket Trap)
*   **Standard Builder:** 23 hours
*   **Powerful Builder:** 5 hours
*   **Megabuilder (Final):** 1 hour 19 minutes

When I first ran `python3-torch` on the Megabuilder, it finished faster than the 5-hour mark, but something was off. Monitoring the system revealed that it was utilizing a maximum of 28 out of the 224 available CPUs. 

After digging into the SPEC file, I found the culprit. The maintainer's parallelism detection logic was correctly counting cores, but it forgot to multiply them by the number of CPU sockets. The Megabuilder has a 4-socket architecture. After submitting a [quick pull request](https://src.fedoraproject.org/rpms/python-torch/pull-request/12) to fix the detection logic, CPU utilization spiked (though it still didn't max out the machine) and the build time dropped to an impressive **1h 19m**.

**The Cost Equation:** The Megabuilder run cost **$35**. On the powerful builder, this same build costs only **$8**. That is a steep premium for speed.

*Sidenote:* At the very end of the build process, `rpmbuild` hung in a single-threaded state doing "something" for quite a while. My educated guess is that it was churning through a `brp` (BuildRoot Policy) script hook.

### Test 2: `gcc` (The `./configure` Bottleneck)
*   **Standard Builder:** 13 hours (Cost: $2)
*   **Megabuilder:** 5 hours 36 minutes (Cost: **$151**)

GCC rarely managed to take advantage of the Megabuilder’s massive core count. If you watch the process tree, the vast majority of the time is spent running one or two `./configure` scripts. A configure script will chug along single-threaded for over a minute, followed by a brief 15-second burst where all cores light up during actual compilation, only to immediately drop back down to a single-threaded `./configure` process. 

Paying $151 to watch a single CPU core parse autotools macros is a tough pill to swallow.

### Test 3: `rust` (The Optimization Trade-off)
*   **Standard Builder:** 4 hours (Cost: $0.70)
*   **Megabuilder:** 2 hours 22 minutes (Cost: **$63**)

Rust was the most resilient to parallelization, but this time, it’s not exactly a bug. As I understand it, this is a deliberate choice by Fedora engineering. If you force highly parallelized Rust builds, the resulting binary ends up being roughly 2–5% slower. Fedora consciously trades longer build times on the infrastructure side to guarantee faster runtime performance for end users. 

### Conclusion: Diminishing Returns

So, does monstrous hardware solve long RPM build times? Only marginally, and at an astronomical cost. 

The reality is that sheer hardware scale is fundamentally bottlenecked by the software architecture. Neither `rpmbuild` itself nor the maintainer code inside `%build` sections can efficiently map to extreme, massive parallelism. You hit [Amdahl's Law](https://en.wikipedia.org/wiki/Amdahl%27s_law) incredibly fast.

**A final funny observation:** Knowing that even on this 224-core monster the builds would take hours, I fired them up fully intending to go watch a movie on Netflix. Instead, I found myself completely mesmerized by `btop` and the output of `ps axf`. Watching process trees expand and collapse across 224 cores turned out to be far more entertaining than a Hollywood blockbuster. :)

[![Btop on megambuilder](/assets/img/posts/btop-megabuilder.png)](/assets/img/posts/btop-megabuilder.png)


