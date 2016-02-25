---
layout: post
title: A Method by Any Other Name
---

A quick post about when I choose to alias methods in Ruby, and when I don't.

---

If you have programmed Ruby at all, you have probably noticed that there are a lot of ways to do one thing.
For example, to raise an error, you can use the `raise` method _or_ you can use the `fail` method.
Both have exactly the same behavior.
In fact, they are exactly the same thing.
If you check out [the docs for `fail`][fail], you'll see... `raise`.
So why have it?
Semantics.

Ruby provides us with the ability to choose the method that best communicates intent.
The late [Jim Weirich][jim] had a somewhat well known semantic for `fail` vs. `raise`.
He would use `fail` for irrecoverable errors (or... failures), and he would use `raise` for errors that may be caught elsewhere.
Avdi Grimm was kind enough to [capture Jim's opinion in a post][avdi].
There are a number of other examples throughout the Ruby codebase, e.g. [Enumerable#inject][inject] and [Enumerable#reduce][reduce].
It's all in the name of writing self-evident code.

## When to alias a method...

In short, alias a method when the new method you're exposing is literally another word for the *same thing*.
Let's check out an example.

### A Part

Here's a snippet of code that was recently discussed in code review.

```ruby
class Foo
  def part
    locate
  end

  private

  def locate
    # some part locating logic
  end
end
```

The comment came on the implementation of `part`.

> Why not just `alias_method :part, :locate`?

It makes sense, the entire implementation of `part` is literally calling another method.
So save a couple lines and make it an alias, right?

This introduces a cognitive "WAT".
Making the `part` method an alias of `locate` states that it literally carries the same semantic meaning as `locate`.
These two methods actually have two distinct purposes.

1. `part` - expose a public interface on `Foo` for getting its `part`.
2. `locate` - do something to find the `part` for `Foo`.

This becomes especially apparent when a new requirement comes in.

> Optimize Foo#part by memoizing the located value.

If you had aliased `locate`, you would now be ripping that out to implement an actual `part` method.

```diff
 def part
-  locate
+  @part ||= locate
 end
```

Beyond this practical advantage, there is also cognitive gain.
You know at a glance of the class that "Foo has a part" rather than "Apparently Foo's locate is also known as a part" (???).

## So when then?

Assume that you have shipped `Foo`.
It's out in the wild and a number of other's depend on the fact that `Foo` has a `part`.
However, you decide that `part` isn't the best name for this data member.
You want to refer to it as `widget` henceforth.

```diff
 def part
   @part ||= locate
 end
+alias_method :widget, :part
```

The reader of your code immediately recognizes that `widget` is just another name for `part`.
But please do consider a [deprecation] message.


[fail]: http://ruby-doc.org/core-2.3.0/Kernel.html#method-i-fail
[jim]: https://en.wikipedia.org/wiki/Jim_Weirich
[avdi]: https://en.wikipedia.org/wiki/Jim_Weirich
[deprecation]: https://en.wikipedia.org/wiki/Deprecation
[inject]: http://ruby-doc.org/core-2.3.0/Enumerable.html#method-i-inject
[reduce]: http://ruby-doc.org/core-2.3.0/Enumerable.html#method-i-reduce
