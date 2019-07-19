---
title: Mock can now parse the log from build
author: Silvie Chlupova
layout: post
---

Into [mock](https://github.com/rpm-software-management/mock) has been added a new feature called [mock-parse-buildlog](https://github.com/rpm-software-management/mock/blob/devel/mock/py/mock-parse-buildlog.py).

This piece of code will help you identify what caused your build to fail. Currently, mock-parse-buildlog knows only two situations that could occur and cause that a build fail. First is that some files are in %buildroot but not in %files and the second one is that some files are in %files but not in %buildroot.

Part of the code has been taken from rebase-helper.

#### An example of how it works

Run as:

`mock-parse-buildlog --path /path/to/log/build.log`

And the result is:

```Error type: Build failed because problematic files are in %buildroot but not in %files```

```Problematic files:
/usr/share/locale/sv/LC_MESSAGES/hello.mo
/usr/share/locale/uk/LC_MESSAGES/hello.mo
/usr/share/locale/pt_BR/LC_MESSAGES/hello.mo
[...]
```

However, if you see an error it means that mock-parse-buildlog couldn't recognize what caused that the build failed thus it cannot determine the problem and help you solve it. And this is the spot where other users of mock can help us. If you know that something once (or more times) caused that your build failed, please let us know by creating a Github issue because the same problem may occur with someone else. We can work together to improve this tool.
