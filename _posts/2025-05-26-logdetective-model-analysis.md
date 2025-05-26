---
title: Log Detective Model Analysis
author: Tomas Tomecek
layout: post
---

Before we start with the comparison, let’s acknowledge a big milestone in the Log Detective project. Our tool now comments on Gitlab merge requests for failed CentOS Stream builds [1]. [Here](https://gitlab.com/redhat/centos-stream/rpms/gimp/-/merge_requests/9#note_2514178124) is an example of such a comment. I picked the first one from the list and in this case, the explanation is just wrong. However, upon examining the "Details", which displays log lines annotated by the drain3 library, you can identify the root cause - files are not present on the expected paths.

Back to the comparison. We have been using the *Mistral 0.2 7B* model in Log Detective for quite some time. It was updated last time in December 2023. 1.5 years is a long time in the development of LLMs. Therefore we decided to compare how Mistral is doing against:
* Gemma 3 12B
* Gemini 2.5 flash
* Granite 3.3 8B

I published all the results in this Github repo: [TomasTomecek/logdetective-model-battleground](https://github.com/TomasTomecek/logdetective-model-battleground)

This was my first time doing such an analysis. I collected 5 different build failures and compared the results on the same set of logs from different models. I haven’t done this in one session — it took me more than a week. I was also updating the code and configuration along the way. Unfortunately, it caused some of the results to be degraded. Please take these results with a grain of salt.

We will use a failed build of *python-typing-extensions* in this blog post. The package build runs a test suite in the `%check` section and this test suite has failed like this:

```
FAILED (failures=20, errors=12, skipped=15)
```

Let’s see how these four models processed this build log. Brace yourself for a lot of text. My commentary follows these results.

## Granite
The provided snippets cover various aspects of an RPM build process, including testing failures, assertion errors, build completion, and a build error. Here's a breakdown of each snippet:

1. **Dictionary Analysis**: A Python dictionary named `test_dict` is defined with three key-value pairs. 'label' is associated with a string data type, while 'x' and 'y' are associated with integer data types. There are no errors or additional context mentioned.

2. **Test Failure**: The test `test_regular_extra_items_legacy` from the test suite `test_typing_extensions.TypedDictTests` failed. The failure occurred at line 1844, but no further details about the cause of the failure are provided.

3. **AssertionError**: The failure in test `test_regular_extra_items_legacy` resulted in an `AssertionError` at line 1846, specifically due to a mismatch between expected and actual frozensets containing 'log_path' and 'log_level'. The actual cause and location of this discrepancy require further investigation.

4. **Multiple Test Failures**: The build process encountered 20 failures, 12 errors, and 15 skipped tests, as indicated by the 'FAILED' status with failure statistics at line 1877. This suggests various issues need addressing in the test suite.

5. **Build Check Failure**: The build process failed during the '%check' stage at line 1879, with the error message "Bad exit status from /var/tmp/rpm-tmp.5QvbcS (%check)". This indicates a non-zero exit status from a script or command executed during the build process.

6. **Build Success**: The build for 'python-typing-extensions-4.13.2-1.fc43.src.rpm' was completed successfully at line 1882, as signified by the build status code (1882,).

7. **Configuration Error**: The build failed in the configuration stage for 'fedora-rawhide-x86_64' platform at line 1888, with the error message 'ERROR: Exception(...)'. This suggests an unhandled exception occurred during this specific build attempt.

8. **Command Failure**: An error occurred when executing the build command for 'python-typing-extensions' on Fedora Rawhide for the x86_64 architecture at line 1894. The command failed, and the build environment setup details are provided for context.

9. **Copr Build Error**: The copr build for the package failed without providing further information at line 1897. This indicates that the build process hosted on Copr encountered an issue, resulting in a failure.

In summary, these snippets highlight multiple issues within the RPM build process, including test failures, assertion errors, build check failures, configuration errors, and a copr build error. Each snippet requires further investigation to pinpoint the root causes and develop appropriate solutions.

## Mistral
The provided RPM build log snippets indicate several errors and failures during the build process of the python-typing-extensions package on the Fedora rawhide platform. Here's a summary of the issues:

1. Testing phase failures and errors:
   - Multiple tests (both failures and errors) were encountered during the testing phase, making the testing process unsuccessful.
   - The specific tests that failed and the reasons for their failure are not provided in the log snippets.

2. Packaging issues:
   - The 'rpmbuild' command execution inside the container environment using systemd-nspawn failed, causing the build to fail. No information about the nature of the error is provided in the log snippets.

3. Copr build error:
   - The build process in the Copr repository also failed, but no error message is given in the provided log snippets.

To diagnose the issue, it is recommended to inspect the system logs and the RPM build output for any error messages that may have been generated during the build process. It's also important to check if there are any updates or changes to the dependencies and the python-typing-extensions package itself that could cause these issues. Additionally, trying to build the package on a different platform or using a different build environment might help identify if the issue is specific to the Fedora rawhide platform or the systemd-nspawn containerization.

## Gemma
The build of the `python-typing-extensions` package failed due to a series of test failures within the RPM build process. The core issue isn't immediately clear from a single error message, but the numerous `AssertionError` exceptions across multiple test suites (`test_stock_annotations`, `test_extra_items_class_arg`, `test_implicit_any_inheritance`, `test_regular_extra_items_legacy`, `test_total`) strongly suggest a problem with the package's type hinting and/or the interaction between different typed dict features. The specific assertion failures indicate discrepancies in expected versus actual set contents, pointing to potential logic errors in how type annotations are being handled or inherited. The final error points to a failing `%check` script within the RPM build, which is triggered by these test failures.

The root cause seems to lie within the `typing_extensions` codebase itself, rather than the build environment, although the complex setup of the mock chroot environment might expose these issues. The failure is likely related to a change in how type hints are processed or handled in the `typing_extensions` library, which is then exposed by the tests.

**Recommended Solution:**

The most practical solution is to investigate the failing tests in the `typing_extensions` source code (`src/test_typing_extensions.py`) and identify the underlying logic errors that are causing the `AssertionError`s.  Specifically, focus on the tests mentioned in the logs (`test_stock_annotations`, `test_extra_items_class_arg`, etc.) to understand the expected behavior versus the actual behavior.  Debugging the code, potentially with a local build and debugging environment, would be necessary to pinpoint the cause.  A fix might involve adjusting the expected values in the assertions or modifying the code under test to align with the intended behavior. After the underlying code is fixed, a new build should be triggered to confirm the fix resolves the test failures.

## Gemini
Based on the log snippets, a failure occurred during the package build process. The build failed specifically during the `%check` stage, which is where the package's test suite is run. Multiple tests failed (indicated by `FAIL:` and `AssertionError` entries), resulting in the test suite reporting `FAILED (failures=20, errors=12, skipped=15)`. This test failure caused the `%check` stage script to exit with a bad status, leading to the `RPM build errors: error: Bad exit status` and the ultimate `Copr build error: Build failed`.

The recommended solution is to investigate the specific test failures reported in the log (e.g., `test_stock_annotations`, `test_implicit_any_inheritance`, `test_regular_extra_items_legacy`, `test_total`) and fix the underlying code or test logic issues that are causing them to fail. Once the tests pass successfully, the build should complete without the `%check` stage failure.

## Commentary
As you can see, the results are different. One feedback we are already hearing from engineers is that shorter is better. LLMs can be pretty verbose, so even when we instruct the model to be concise, quite often it’s not.

We’ll start with Gemini. The comment from this model is just perfect. Short, straight to the point, no extra sentences. If I asked a senior engineer for help, this is the message I would want to see.
Gemma is also pretty good though it lacks confidence, especially when you compare it to Gemini. They are similar but Gemma produced more words, lacks confidence, and clearly doesn’t understand the structure of the RPM build process.

Let’s continue with Mistral. It reads pretty poor when compared to Gemma, and especially Gemini. It completely lacks details (names of tests), contains irrelevant information, and therefore provides very little value to an engineer. I would absolutely need to see the logs to understand what went wrong.

Granite [2] results are interesting. They read as a summary of the log, which makes sense because that’s how we structure the final prompt. I can see value in this type of output, but at the same time it’s not the correct answer - telling me why the build has failed in a few clear sentences.

Based on this analysis it’s clear to me that we need to upgrade our model. Soon!

[1] This applies to RHEL as well since the builds are 99% identical, hence we decided to pick CS builds because they are completely open  
[2] I also added results from Granite 3.1 in the Github repo, though unfortunately they are very poor compared to all the other models  

