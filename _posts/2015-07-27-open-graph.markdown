---
layout: post
title: Open Graph Protocol
description: Adopt the Open Graph protocol in you site's head for great good!
---

My annoyance at how links were being displayed in Slack finally reached a tipping point.
They _had_ to be more useful than they were being.
TIL [Open Graph][open-graph].

As their website says:

> The Open Graph protocol enables any web page to become a rich object in a social graph.
> For instance, this is used on Facebook to allow any web page to have the same functionality as any other object on Facebook.

Basically make things go from this:

---
<img width="500" src="/img/blog/2015/07/before.png" alt="before open graph">

To this:

---
<img width="800" src="/img/blog/2015/07/after.png" alt="after open graph">

## How even?

It's nbd, just a few tags to add to your page' `head`.

* `og:site_name` - The name of the site being referenced.
* `og:title` - The title of the page being referenced.
* `og:type` - Type type of content being reference. Mine are all "website".
* `og:image` - An image to describe the link.
* `og:url` - The canonical URL of the page.

Here's the source from my blog:

<script src="http://gist-it.appspot.com/https://github.com/iamvery/iamvery.github.com/blob/5187793b1bfd624dde029f37f380e3b36eaf70d1/_layouts/default.html?slice=13:18"></script>

---
<img width="800" src="/img/blog/2015/07/annotated.png" alt="annotated screenshot of a slack-rendered link">

---

## That's it

Check out the [full Open Graph protocol][open-graph] for all the details in making those links look good!
As it turns out, [Twitter also has a protocol for these things][twitter-cards].
May be worth checking out!

[open-graph]: http://ogp.me/
[twitter-cards]: https://dev.twitter.com/cards/markup
