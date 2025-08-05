---
title: Log Detective dataset has been published
author: Jiri Podivin
layout: post
---

Since the start of Log Detective project, we have been gathering annotations for failed RPM builds
on our website www.logdetective.com.
Our intention was always to publish the collected data under open license[1] and use it to improve
experience of packagers across Fedora ecosystem.

After gathering slightly over 1000 contributions we have published our dataset[2]
on the Hugging Face platform in a QnA format, to facilitate its use in fine tuning LLMs.

In this post I'll outline the steps taken to create the dataset, and ways the dataset can be used.


## From annotations to dataset

Before uploading the data, it was necessary to preprocess gathered annotations.
Comments on some of the submitted logs were exceedingly short and lacking meaningful information.
While other records were corrupted. The full source of script used to transform annotations into dataset is present in
the dataset repository on Hugging Face, but here we can go over the most pertinent parts.

Individual `.json` files containing annotations were converted into rows of pandas DataFrame to simplify queries and manipulation. Each of the rows contained the name and contents of the parsed `.json` file. 

For each of the entries, several utility columns were calculated to facilitate further work.


### Sanitizing dataset

Original setup of our annotation interface was too permissive, so some submissions were
not suitable for use. As a remedy, several simple rules were applied to remove annotations
that were unsuitable for further work:

1. Descriptions of issues and fixes shorter than `10` characters are not useful.
2. Submissions without annotated snippets are not useful.
3. Submissions with total length of snippet annotations shorter than `10` characters are not useful.
4. Submissions with snippets set to `None` are not useful.

With the last rule covering annotations that were corrupted.

Pandas library allows us to define filters as simple conditionals.
Turning the aforementioned rule list into straightforward code:

```
almost_empty_fix = dataset["how_to_fix_len"] < min_how_to_fix_len
almost_empty_reason = dataset["fail_reason_len"] < min_fail_reason_len
almost_empty_snippet_annotations = (
    dataset["tot_snippet_annot_len"] < min_total_snippet_annot_len
)
none_snippets = dataset["logs"].apply(none_snippet)
```

All conditionals can then be used as part of a single formula, to filter out all annotations that satisfy any of them.

```
sparse_annotation_criteria = (
    almost_empty_snippet_annotations
    | almost_empty_reason
    | almost_empty_fix
    | none_snippets
)
```

Inversion of the result will give us indices of all annotations that satisfy our minimal requirements.


### Splitting the into subsets

The dataset was then split into two constituent parts, training and test, this is important for future use
in training of LLMs. The dataset was randomly shuffled before the split, to prevent bias in order of annotations.

The seed was set, for replicability, to `42`.

```
def split_dataset(dataset: pd.DataFrame, seed: int):
    """Splits dataset into training and evaluation subset"""
    split = dataset.shape[0] // 5
    dataset = dataset.sample(frac=1.0, random_state=seed)
    train_dataset, test_dataset = dataset[split:], dataset[:split]

    return train_dataset, test_dataset
```

### Transformation into question/answer pairs

Training of models based on artificial neural networks, Large Language Models or otherwise,
involves formulating your data in form of `x -> y` where `x` is your expected input
and `y` is your expected output.

Most obvious use of dataset, would be to fine tune an existing instruction tuned model, imbuing it with information about RPM build failures. Instruction tuned models, such as ibm-granite/granite-3.3-8b-instruct [3], are trained with data in a chat form. These often come in a form of answers and questions, or instructions and actions performed.

If we want to appropriately leverage existing capabilities of the model, we must follow the same
form, or risk catastrophic forgetting.[4] This means that we need to transform our annotations into pairs of questions and answers. Prompts used by Log Detective [5] can serve as bases for these.

Each of our annotations consists of explanation, proposed resolution and one or more log snippet annotations. We can turn each of the snippet annotations into it's own question/answer pair, and create one more for the resolution and explanation. 

This means that our dataset will, effectively, contain more entries than we have annotated logs.

### Uploading

Both training and test subsets are combined into a single object and uploaded to Hugging Face.

```
dataset = {
    "train": datasets.Dataset.from_list(train_dataset),
    "test": datasets.Dataset.from_list(test_dataset),
}

dataset = datasets.DatasetDict(dataset)

dataset.push_to_hub(repo_id=repo_id, private=True, token=hf_token)
```

Keeping the upload initially private is a good idea, unless you are absolutely certain about correctness of your data sanitation and formatting.

 
## How to use the dataset

To use the new dataset, you can simply clone the repo using git, or access it using Hugging Face datasets library:

```
from datasets import load_dataset

ds = load_dataset("fedora-copr/log_detective_qna")
```


[1] https://cdla.dev/permissive-2-0/

[2] https://huggingface.co/datasets/fedora-copr/log_detective_qna

[3] https://huggingface.co/ibm-granite/granite-3.3-8b-instruct

[4] https://en.wikipedia.org/wiki/Catastrophic_interference

[5] https://github.com/fedora-copr/logdetective/blob/main/logdetective/prompts.yml