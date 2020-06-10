---
title: Runtime dependencies in Copr
author: Dominik Tureček
layout: post
---

In the last release, we've added support for runtime dependencies in Copr. If your project needs another package to run, but you don't need said package as a part of your project, you can have it as a runtime dependency instead. You can now specify other repositories (either Copr projects or external) as runtime dependencies. These repositories will then be enabled alongside your Copr project.

We are currently testing the feature and are looking for users' feedback - please share any issues that you might find. Later, once this feature is tested, we plan to generalize it and add it to dnf and createrepo_c as well.

### How to add runtime dependencies to your Copr project
To add runtime dependencies to your Copr project, navigate to your project's `Settings/Project Details` tab. There, in `Other options`, is a field `Runtime dependencies` where you can specify a space-separated list of dependencies:

 * To specify another Copr project as a runtime dependency, add `copr://user-name/project-name`.
 * To specify an external repository as a runtime dependency, add a URL to its repo file.

![Runtime dependencies field in project's settings.](/assets/img/runtime-dependencies/runtime-dependencies-1.png)

You can specify as many runtime dependencies as you want. Note that the runtime dependencies are resolved transitively, e.g., if your `ProjectA` depends on `ProjectB` and `ProjectB` depends on `ProjectC`, then `ProjectA` will have both `ProjectB` and `ProjectC` as its dependencies.

### Enabling a project with runtime dependencies
So, if I enable a Copr project that has a bunch of dependencies, how do I know what repositories I actually enabled? First, you can see a list of all runtime dependencies on the project's `Overview` tab:

![List of runtime dependencies of a Copr project.](/assets/img/runtime-dependencies/runtime-dependencies-2.png)

Second, if you download a repofile of such a project, it lists all the dependencies. And last, if you are using the dnf copr plugin for enabling Copr projects (using the `dnf copr enable` command), it will notify you about all the dependencies. Although the dependencies come enabled by default, the dnf copr plugin gives you an option to disable them.

![Dnf warning when enabling a project with dependencies.](/assets/img/runtime-dependencies/runtime-dependencies-3.png)
