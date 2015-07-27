---
layout: post
title: Shortcut, Long Pain
description: Be wary of shortcuts, they don't always make things easier.
---

Programmers are often tempted to take the shortest route possible to deliver a
feature. While there is a lot to be said about pragmatism, every decision has
consequence. Make the best possible decisions.

![Convenience of code hinders clarity](/img/blog/2015/02/convenience-hinders-clarity.jpg)

## Shortcut

You receive a feature request. You are to implement a view for pet management.

> A pet has 4 attributes:
>
> * name (required): Emme
> * color: brown
> * size: medium
> * species (required): dog
>
> Create an interface allowing a pet to be edited. The editable fields are
> displayed in the order: name, species, color, and size. The order is
> required to support [BEAUTIFUL INTERFACE].

To reduce duplication, you decide to iterate over the collections of fields.

~~~
required_fields = ["name", "species"]
other_fields = ["color", "size", "owner"]
~~~

Your view looks like this:

~~~
<% required_fields.each do |field| %>
  <%= f.text_field field, required: true %>
<% end %>

<% other_fields.each do |field| %>
  <%= f.text_field field %>
<% end %>
~~~

Conveniently, this renders the required fields at the top and the other fields
below just as the feature was requested.

## Long Pain

Some time passes and the client is back with a new feature.

> A pet's size is a required field. Preserve current order.

The best we can do is break out of the "other fields" iteration.

~~~
<% required_fields.each do |field| %>
  <%= f.text_field field, required: true %>
<% end %>

<%= f.text_field "color" %>
<%= f.text_field "size", required: true %>
<%= f.text_field "owner" %>
~~~

You had to give up the convenience of looping over the fields to display the
last set. Further, it seems a little odd that "size", a required field, is not
included in the `required_fields` collection.

As it turns out, the programmer convenience of iterating over these fields to
save some keystrokes should not have been captured in the code. This is an
example of [coincidental duplication](coincidental-duplication). If you want
to save typing, try setting up [macros](emmet) in your [text](vim-macros)
[editor](sublime-macros). Convenience of tool helps you. Convenience of code
hinders clarity.

<blockquote class="twitter-tweet" lang="en"><p>Writing code is like writing a book, your efforts are for _other_ readers.</p>&mdash; Sandi Metz (@sandimetz) <a href="https://twitter.com/sandimetz/status/566273151315623938">February 13, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

What other examples of painful shortcuts have you seen in code?

[coincidental-duplication]: http://www.rubytapas.com/episodes/89-Coincidental-Duplication
[emmet]: http://mattn.github.io/emmet-vim
[vim-macros]: http://vim.wikia.com/wiki/Macros
[sublime-macros]: http://sublimetext.info/docs/en/extensibility/macros.html
