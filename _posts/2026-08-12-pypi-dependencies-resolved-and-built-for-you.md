---
title: PyPI dependencies, resolved and built for you
author: Sundaram Krishnan
layout: post
---

Say there is a Python package on [PyPI](https://pypi.org/) that you would like to build in Copr. And the project itself is not packaged in Copr or
in the Fedora repositories, and neither are all of its dependencies.
So the manual way of doing it would be to check which of its dependencies are not yet packaged in Fedora and build them in the right order.
Miss a dependency and you only find out several minutes later, from a build
log.

The `--with-deps` option does all of that work for you. It finds the dependencies that are missing, works out the order they have to be built in, and submits them:

    copr-cli buildpypi <project_name> --packagename <package_name> \
        --with-deps --chroot <chroot>

[![Demo dependency tree](/assets/img/posts/copr-cli-with-deps.png)](/assets/img/posts/copr-cli-with-deps.png)

## Where the dependency resolution happens

All of it happens on the client side, in `copr-cli` itself.

The [coprtree](https://github.com/sundaram123krishnan/coprtree) library reads
the dependency metadata from [ecosyste.ms](https://packages.ecosyste.ms),
prunes everything that is already available in the official Fedora repositories or your Copr project and topologically sorts what is left into build levels.

The pruning is what keeps the tree small. Most of a package's dependency graph
is usually already in Fedora, and there is no reason to rebuild it.

The idea of teaching `copr-cli` to build a whole dependency tree at once came
from [Jakub Kadlčík](https://github.com/frostyx).

## Important notes

- Only PyPI packages and Fedora chroots are supported for now. Support for
  other package managers and distributions is planned.
- Exactly one `--chroot` has to be specified for now. Support for multiple
  chroots will come later.
- `--with-deps` needs the coprtree library, which is an optional dependency of
  `copr-cli`. Install it with `dnf install python3-coprtree`.

The dependency resolution is still in its early stages, so expect some rough
edges. If a resolved tree looks wrong, please report it to
[coprtree](https://github.com/sundaram123krishnan/coprtree/issues).
