# The Copr Blog

<https://fedora-copr.github.io/>


## How to write a post

Here is the recommended workflow how to submit a new post.

### Workflow

1. Fork and clone the repo
2. Add a new file in `_posts` or `_drafts`
3. Write the content of your post
4. Run the page locally and see your changes
5. Send a pull request


### Posts vs drafts

Most likely you want to create a post which is labeled by date and appears on the front page right after merging the pull request. Such posts are named `YYYY-MM-DD-name.md` and located in the `_posts` directory. If you wish to create a draft and not release it just now, have your file in the `_drafts` directory. The filename for drafts doesn't contain the date part.


### Standard vs external posts

Do you want to host your post on this site or just create a record of your post and point it to your personal page?


#### Standard post

This page is built on Jekyll, see an official documentation how to write a post <https://jekyllrb.com/docs/posts/>. Just make sure to use front-matter header with following attributes

    ---
    title: <some title>
    author: <full name>
    layout: post
    ---


#### External post

If the post was already published on some page and you want to publish it also here, you can duplicate the post, but more preferably create a post like this

    ---
    title: <some title>
    author: <full name>
    layout: post
    external_url: <link to your post>
    ---


### Text formatting

As it is apparent from posts filename extension `.md`, they are formatted in [Markdown](https://daringfireball.net/projects/markdown/syntax). It has very simple formatting syntax which can be learned in several minutes. It supports mixing-in an HTML tags for complicated things, but please treat them with care. The best thing you can do before writing a new post is opening any of existing posts in the text editor.


### See your changes locally

Don't get scared by the fact that you should run something locally. You don't have to. However, if you want to see, how the post will look once we release it, run this page locally. It is no more than

    bundle install
    bundle exec jekyll serve --incremental --drafts
