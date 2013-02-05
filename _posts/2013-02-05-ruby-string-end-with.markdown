---
layout: post
title: Ruby String#end_with?
---

**TL;DR** Use Ruby's String#end_with? to check a string for suffixes!

For a recent Rails project, I needed to exclude a number of strings from an array
if they ended with any of several difference suffixes. After coming up with a
[questionable solution](http://localhost:4000/2013/02/05/ruby-array-fuzzy-include.html),
I discovered Ruby's String#end_with? method! The solution is simple and idiomatic.

{% highlight ruby %}

    suffixes = %w(abc def ing)
    %w(something abcdef other_things).delete_if do |item|
      item.end_with? *suffixes
    end
    # => ["other_things"]

{% endhighlight %}

Notice you have to "splat" the suffixes array. This is because `end_with?` takes
any number of suffixes as arguments rather than an array.
