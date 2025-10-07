---
title: Generating dataset from Fedora packaging guidelines
author: Jiri Podivin
layout: post
---

Recently we have published a [dataset](https://huggingface.co/datasets/fedora-copr/packaging-qna) of sourced questions and answers about Fedora packaging [guidelines](https://docs.fedoraproject.org/en-US/packaging-guidelines/) to Hugging Face. With the intention of using it to fine tune LLMs.

In this blog post, I will describe the approach I have taken to generate it. Focusing on matters of prompt construction, and response constraints.


## Question of data

Fine tuning large language models to behave according to user instruction,
requires a very specific structure of training data used. One can not simply
take various documents, no matter how well formed or sourced, and use them
as targets for training algorithm.

Doing so, would simply teach the model to reproduce the very same documents,
in the best case. Far more probably, the model would produce many variations
of the documents given during training. Some are more plausible than others.
But all invariably useless.

Instead we need to provide model with inputs and outputs in the same format
that will be present, and expected, during operation.
That is, conversation samples. With questions, as if asked by user, and answers,
grounded in source documents.

The question remains, how to accomplish this at scale. Fine tuning, while cheaper
than a full training run, does require many thousands of samples for stable results. Creating samples manually, is simply not viable, even under very optimistic assumptions.

## Leveraging LLMs

The answer lies in using LLMs. Language manipulation is what they were created for, after all.
Having LLM generate enough samples is a simple matter of writing a prompt, setting a loop and going for a cup of coffee, or going to sleep. That depends on how many samples you want and what kind of hardware is available.

But how can we be sure that model will produce samples that are grounded in reality?
After all, if the model already possessed the required domain knowledge, what purpose would any fine tuning serve?

There is also a much more straightforward issue of controlling and parsing the output. The model has to be called many times, and each time the output has to be transformed into a training sample. This process has to be as reliable as possible. Every call costs us money, or time, and we don't have an infinite supply of either.


### Grounding the LLM

To ensure that samples produced are grounded in truth, we need to provide a trustworthy source for model to use when generating them. This simplifies the task considerably, as the model is now merely transforming one kind of text into another.

With a well structured prompt, we can put strong emphasis on the source, lowering the chance of the model producing ungrounded samples considerably.

System prompt bears the most weight here, priming the model to provide responses we need. Emphasis has to be placed on source of knowledge to be used, and on contents of the output. 

At the same time, restrictions are placed on what must **not** be included in model responses. Otherwise we may end up with samples that are seemingly reasonable, but providing no domain knowledge. 

Providing an example is another way to improve the quality of the output.

```python
EXTRACTION_SYSTEM_PROMPT = """
You are a meticulous AI assistant designed for high-precision information extraction.
Your primary function is to create specific, fact-based question-and-answer pairs directly from a provided document.

Your task is to adhere to the following strict principles:

1.  **Absolute Grounding:** Every answer you provide MUST be a direct, verbatim quote from the source document. Do not summarize, paraphrase, or infer information.
2.  **Question Specificity:** Questions must be specific and target concrete details (e.g., names, numbers, locations, reasons, processes, definitions). Avoid overly broad or ambiguous questions that could have multiple interpretations. Questions should target information that is unique to the document.
3.  **Self-Contained Questions:** A question should be understandable on its own, but the answer must only be verifiable by consulting the provided document.
4.  **No External Knowledge:** You must operate exclusively on the information within the document. Do not use any prior knowledge.
5.  **Exclude Metadata:** Do not generate questions about the document's own properties, such as its author, title, filename, publication date, or revision history. Focus exclusively on the subject matter content within the text.
6.  **Output Format:** Your response will be a single JSON object containing a list of Q&A pairs. Each pair will have three keys: "question", "answer", and "question_topic".

Example of a GOOD question:
- "What specific percentage of the budget was allocated to research and development in the final quarter?"

Example of a BAD (too vague) question:
- "What does the document say about the budget?"
"""

```

The source document can be used as part of much less complex, user level, prompt.

```python
BASE_EXTRACTION_PROMPT = """

Attempt to create as many high quality question / answer pairs from following document as possible.
Multiple variants of the same question / answer pair are allowed. As long as the meaning remains unchanged

Document:
'''
{document}
'''
"""
```

These principles are generally applicable to use of LLMs in various scenarios. Although there may be subtle differences in effectiveness of various approaches to prompting between models, the basic idea of stating purpose, setting constraints and providing examples, remains largely unchallenged.


### Structuring model output


Structured output provides an easy solution to the second problem.
It allows users to specify an exact format which the LLM output must follow. This feature has been supported by OpenAI for some time, and it has proliferated among self-hosted, FOSS inference providers, such as vLLM or llama.cpp.

The format can be specified as a JSON schema. With pydantic, we can create a model, which will provide us with both schema specification, and validation.

While the set of JSON features supported by different providers differs, and is never complete, it is generally sufficient for most purposes.

We can specify type and various constraints on fields, such as length or range of values.

For example, this model sets the structure of a single question/answer pair. This would be one sample in our dataset.

```python
class QnAPair(BaseModel):
    """Single Q/A pair with topic."""

    question: str = Field(description="Question about contents of the document.")
    answer: str = Field(description="Answer to the question")
    question_topic: str = Field(description="Topic of the question.")

```

We can also request multiple samples at the same time.
By asking for a list of objects we have already defined.

```python
class QnAList(BaseModel):
    """List of Q/A pairs."""

    questions_and_answers: List[QnAPair] = Field(
        description="List of questions and answers about given document.", min_length=1
    )
    document_topic: str = Field(description="Topic of the document")
```

### But we need more

It is very unlikely that a single pass through source document would produce all the samples we need. At very least, we are likely to fill the model context at some point.
Simply executing the same call repeatedly, could work. But it would be liable to produce multiple samples with almost, or completely, identical contents.

In order to reach a reasonable number of samples, we need a way to consistently generate multiple variants of those we already have. And again, LLMs can be leveraged to give us exactly that.

This task is much easier than the original one. Because it isn't strictly necessary to get more varied answers. Provided that those we have are of sufficiently high quality.

If we want our fine tuned model to be robust enough for deployment, it needs to be able to respond to a wide variety of **questions**.


With the new format for model responses, we can ensure that we only get questions. Sparing some tokens.

```python
class QuestionVariant(BaseModel):
    """Variant of base question"""

    question: str = Field(description="Variant of an existing question.")


class QuestionVariantList(BaseModel):
    """List of question variants."""

    question_variants: List[QuestionVariant] = Field(
        description="List of question variants.", min_length=1
    )
```

The prompt also needs adjustments. But established principles still apply here.

```python

VARIATION_SYSTEM_PROMPT = """
You are an AI assistant specializing in linguistics and question reformulation. Your task is to rephrase a given question in multiple ways while strictly preserving its original intent and meaning.

Follow these rules:
1.  **Preserve Core Intent:** All generated questions must request the exact same piece of information as the original. The answer to all variants should be identical to the answer of the original question.
2.  **Maintain Specificity:** Do not make the questions more general or vague. If the original asks for a percentage, the variants must also ask for a percentage.
3.  **Vary Phrasing and Structure:** Use synonyms, change the sentence structure (e.g., active to passive), and reorder clauses to create natural-sounding alternatives.
4.  **Output Format:** Your response will be a single JSON object containing a list of dictionaries. Each dictionary will have only one key: "question".
"""

VARIATION_USER_PROMPT = """
Here is the original question:
{question}

Please generate {n_variants} distinct variants of this question.
"""
```

### Sourcing the questions

Before we can get started with generating the dataset, we should ensure that all samples we create can be tracked back to source.

```python
for qna in parsed_response.questions_and_answers:
    base_qna.append(
        SourcedQnAPair(
            question=qna.question,
            answer=qna.answer,
            question_topic=qna.question_topic,
            source=file_path,
            document_topic=parsed_response.document_topic,
        )
    )
```

This will help us with quality control. As we can later track down the exact source document used, and verify that information in the answer is indeed accurate. 


### Putting it all together

With model handling both knowledge extraction and dataset augmentation, the task of building a large Q/A dataset becomes much more tractable.

All that remains is putting these tasks into loops. First for iterating over all source documents, deriving base questions. Second for deriving new question variants.

Depending on structure of source documents, and context size of the LLM, it may be prudent to split documents in sections. A number of heuristics can be employed to that end, starting with simple splitting by certain number sentences, or by section headings.

In the case of Fedora Packaging guidelines, all documents are nicely formatted `.adoc` files, of limited [size](https://pagure.io/packaging-committee/blob/master/f/guidelines/modules/ROOT/pages), and we can use them without change.

Created questions and answers, all `SourcedQnAPair` objects supporting [serialization](https://docs.pydantic.dev/latest/concepts/serialization/#modelmodel_dump), can be easily converted into a list of dictionaries, and finally into a Hugging Face dataset.

```python
# Dicts to dataset
dataset = []
for e in tqdm.tqdm(final_qna):
    row = e.model_dump()
    dataset.append(row)

random.shuffle(dataset)

dataset = datasets.Dataset.from_list(dataset)
```

Shuffling is largely optional, and can be left on the consumer of the dataset to be applied before the dataset is split into training and testing subsets.

Apart from publishing dataset on Hugging Face, we can save it locally, in any of the supported formats.

```python
dataset.to_parquet("fedora_qna.parquet")
```

## Limitations

While this approach is certainly powerful and useful, it is not perfect.
LLMs, even when grounded with source documents and well crafted prompts, are capable of producing text without foundation in input.

Even when this is not the case. Source documents ought to be checked. To verify that no private or sensitive information is present. Otherwise they may leak into newly created dataset and any models trained using it.

Finally, and this is the most important limitation of all. Even the best dataset can not supplant deficient fine tuning procedures. Nor can it balance issues caused by a model that is just too small for the task. 

It is always necessary to consider all aspects of fine tuning and setting expectations accordingly.
