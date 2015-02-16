---
layout: post
title: Shortcut, Long Pain
---

Programmers are often tempted to take the shortest route possible to deliver a
feature. While there is a lot to be said about pragmatism, you should be
considerate of consequences to make the best decision possible.

## Shortcut

You are hard at work on a web application, and you're given a feature to create
a view for pet management.

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

To reduce duplication you decide to iterate over collections of fields.

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

> A pet's size is a required field. Current order is preserved.

The best we can do is break out of the "other fields" loop.

~~~
<% required_fields.each do |field| %>
  <%= f.text_field field, required: true %>
<% end %>

<%= f.text_field "color" %>
<%= f.text_field "size", required: true %>
<%= f.text_field "owner" %>
~~~

You have had to give up the convenience of looping over fields to display
the last set. Further, it seems a little odd that "size", a required field, is
not included in the `required_fields`.

As it turns out, the programmer convenience of iterating over these fields to
save some keystrokes should not have captured in the code. This is an example
of [coincidental duplication](http://www.rubytapas.com/episodes/89-Coincidental-Duplication).
If you want to save typing, try setting up macros in your text editor.
Convenience in your tools helps you. Convenience in code hurts readability.

<blockquote class="twitter-tweet" lang="en"><p>Writing code is like writing a book, your efforts are for _other_ readers.</p>&mdash; Sandi Metz (@sandimetz) <a href="https://twitter.com/sandimetz/status/566273151315623938">February 13, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

What other examples of painful shortcuts have you seen in code?
