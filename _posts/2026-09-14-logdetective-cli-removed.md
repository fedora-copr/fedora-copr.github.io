---
title: Removing Log Detective CLI and other Log Detective News
author: Jan Matufka
layout: post
---

Log Detective has not been used as a CLI tool for quite some time, especially
since the release of v4, where the server's `/analyze` endpoint was rewritten
to an agentic workflow built with
[beeai-framework](https://github.com/i-am-bee/beeai-framework).

All dependent services ([Log Detective website](https://www.logdetective.com),
Packit, Copr, etc.) utilize the `/analyze` endpoint on Log Detective servers,
since our production offers a larger model, giving better and faster responses.

The original idea for the Log Detective CLI tool was that someone could
run a custom, locally hosted LLM fine-tuned to their specific use case,
provided they had enough data.
In practice, no one (that we know of) followed through with this,
instead relying on the server we maintain.

The Log Detective CLI thus slowly began to feel like more of a
**maintenance burden**, often duplicating some functionality between
server and CLI, and requiring extra architectural complexity to cater to both.

Now, we are in the middle of adapting our codebase to also analyze
**test logs from Testing Farm**, a big step justifying a **major release**.
And because the CLI is nowadays more of an afterthought, rather than a priority,
it is removed in the Log Detective v5.0.0 release.

## New asynchronous API in Log Detective v5

One of the requirements stemming from our plans for Testing Farm integration
was to transition Log Detective server's API to asynchronous.
Requests to `/analyze` now return `202 Accepted` with a `Location` header
pointing to `/tasks/{id}` instead of immediate results.
Clients must then poll `GET /tasks/{id}` until the task status reaches `done`
to retrieve the final analysis payload from the result field.
The response payload has also been simplified to:

```json
{
  "explanation": "Failure explanation.",
  "no_issue_found": false,
  "snippets": [
    {
      "line_number": 42,
      "source_file": "build.log",
      "text": "Line obtained from the log by some extractor tool."
    }
  ],
  "solution": "Optional experimental feature suggesting a possible fix."
}
```

Clients can also supply an optional UUIDv4 `id` in request bodies for retries,
and enqueued tasks can be cancelled with `DELETE /tasks/{id}`.

References:
- [Log Detective README.md](https://github.com/fedora-copr/logdetective#usage)
- [New API documentation](https://github.com/fedora-copr/logdetective/tree/main/docs/api.md)

## Emoji Feedback Collection Removal

We also removed the emoji feedback collection from the server. Originally, we
thought that this might be a good way of collecting feedback on the usefulness
of Log Detective's analysis in GitLab MR comments. Users would upvote
👍 or downvote 👎 the analysis, giving us important
stats, and indicating whether or not our service is useful and improving.

However, ever since this feature was in production (April 2025),
on more than 2,200 analyses across almost 1,400 distinct MRs,
we **only collected 79 reactions** (as of Sep 3rd, 2026).

The feedback's low volume and sparsity unfortunately led us to the conclusion
that this was a dead end. We will draw whatever insights we can from the data,
but starting with v5, your feedback will no longer be collected this way.
We are sorry this feature did not yield the results we hoped for, and we
sincerely thank everyone who left feedback, your input was truly appreciated.

## Turning User-Annotated Logs into Agent Context

At the start of the initiative behind Log Detective, we tried collecting data
about some specific build failures and interesting log message interpretations.
We encouraged package maintainers to provide logs with their annotations
via our [website](https://www.logdetective.com).

The data was intended for fine-tuning the language model for
analyzing RPM build logs. Our first target was a thousand annotated logs.
As it turns out, this is far too small to provide tangible improvements.

By the time we could collect enough quality data for effective fine-tuning,
the progress in newer language models' efficiency would easily overtake
any in-house specialized solution.

Unfortunately, this was the case, and the annotations sat unused on a disk
for months. We thought it would be wasteful to not utilize the work some
of our colleagues and users put into providing us with their know-how via
these log annotations.

The transition to agentic Log Detective mid-2026 provided us with
an opportunity. During the agent's workflow, we could use a **tool** to
**access the annotations** and enrich the agent's context.
So we turned the data into something similar to
a [RAG](https://en.wikipedia.org/wiki/Retrieval-augmented_generation),
or a sort of database. The snippets (small verbatim log sections)
are turned into **embedding vectors, searchable by semantic similarity**.

The Log Detective agent during its workflow can choose some log snippet from
its input and search the database for the most similar annotated log snippets.
Each such annotated snippet is then associated with its meaning or
interpretation, the overall build failure reason, and proposed solution
(all provided by users during annotation). This information is then inserted
into the next iteration of the agent's workflow, and can improve the agent's
accuracy, especially in cases where the build failure is not so explicit or
obvious from logs themselves. So now, the logs you annotated, the work
you put in, is finally reflected in Log Detective's responses! Thank you.
