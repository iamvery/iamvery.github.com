---
layout: post
title: On Elixir's Deprecation of Barewords
tags:
- Elixir
---

I subscribe to the [Elixir language core mailing list][core-list] as a means of keeping my finger on the pulse of the language. A [post of particular interest][the-post] has recently fired up the discussion. **Elixir 1.4 introduces a warning for function invocation without parenthesis.** This style, commonly referred to as "barewords" makes variables and zero-arity function invocations look syntactically identical.

```elixir
self # Q: Is it a local variable or a function with no arguments? A: It Depends.™
```

**To date, I have never written a line of Elixir that violates my strict loyalty to barewords style, but today I'm fine with this change.** Given a little reflection and the well-stated reasons for the change in the above-reference post, I'll go along with the ride. Allow me to explain.

## Functions and Values

Elixir is a functional programming language. As such Elixir maintains a strong distinction between functions and values (data). Values do not have functionality. You cannot invoke a _method_ on a value as you might in an object-centric language like Ruby. If you wish to perform some work on a value, it is passed as a parameter to a function.

The barewords style that I have grown to love acts to subtly obscure this distinction. You must look around in context to determine whether a bareword is simply a reference to a variable or a function invocation that may very well cost computation. As much as you may want a bareword function to read as a _value_, a value it is not. At the simplest it's a function that returns a literal at which point, you might want to check out module attributes or macros.

Barewords also introduce some ambiguity that can lead to real confusion. For example, there was recently [a subtle bug][bug] in the [elixirkoans.io][koans] project that would have been caught with this warning. Having forgotten to name a parameter in the function, things went on "working" because the zero-arity function `Kernel.node/0` was automatically included.

**It feels a little offputting to me that a function (zero-arity) might be masquerading as a value (bareword).** The small parenthetical tax paid to reinforce the function/value distinction seems worth it.

## Change is Hard

It's always hard to lose something you love, but these struggles are inevitable. I am very thankful for José and team for being willing to make the hard decisions to keep the language lean and spry. Keep up the fine works, folks.

Here's to you fig leaf operator `()`. 🍻 Keep us from baring all.

h/t [@CodingItWrong][ciw] for the "fig leaf" metaphor



[core-list]: ttps://groups.google.com/forum/#!topic/elixir-lang-core
[the-post]: https://groups.google.com/forum/#!topic/elixir-lang-core/Otz0uuML764
[koans]: https://elixirkoans.io
[bug]: https://github.com/elixirkoans/elixir-koans/pull/134/commits/a2e3fe6d93b14e9105238f85554c8661e8ad9c53
[ciw]: https://twitter.com/codingitwrong