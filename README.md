# Copr blog

<https://fedora-copr.github.io/>


## How to write a post

There are three options to be considered when creating a new post.

1. Standard post
2. External post
3. Remote-included post


### Standard post

This page is built on Jekyll, see an official documentation how to write a post <https://jekyllrb.com/docs/posts/>. Just make sure to use front-matter header with following attributes

    ---
    title: <some title>
    author: <full name>
    layout: post
    ---


### External post

If the post was already published on some page and you want to publish it also here, you can duplicate the post, but more preferably create a post like this

    ---
    title: <some title>
    author: <full name>
    layout: post
    external_url: <link to your post>
    ---


### Remote-included post

If the post was already published and is written in Markdown, you can remote-include it's content like this

    ---
    title: <some title>
    author: <full name>
    layout: post
    ---

    {% remote_include https://<some page>/<filename>.md %}
