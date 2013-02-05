---
layout: post
title: Ruby Array#fuzzy_include?
---

**Update**: After writing this, I discovered a [better method](http://localhost:4000/2013/02/05/ruby-string-end-with.html)
for solving this problem. I thought it worth going ahead and publishing this
post since I took the time to write it. Maybe there's some good buried in here
somewhere. I think my favorite part of the below idea is its use of `inject`. It
uses short-circuited logic to quickly match during the injection loop. Live and
learn! :)

For a recent Rails project, I needed to exclude some items from an `Array`. The
problem was I needed to exclude items that matched certain patterns rather than
the exact strings. So `my_arr - excluded_items` was out.

Say we have an array that looks like this:

{% highlight ruby %}

    an_array = %w(something_suffix1 something_with_this_also and_this)

{% endhighlight %}

And we want to exclude any elements containing the string `"_with"` or
`"_suffix1"`.

### Introducing `Array#fuzzy_include?`
[https://gist.github.com/iamvery/4692735](https://gist.github.com/iamvery/4692735)

{% highlight ruby %}

    class Array
      def fuzzy_include?(search_value, regex_format = '%s')
        inject(false) do |is_found, array_value|
          is_found or !!(search_value =~ /#{regex_format % array_value}/)
        end
      end
    end

{% endhighlight %}

This method will see if the any of the array's items match the given string. It
uses each value of the array as a regular expression against the given value.

The above problem can be solved by:

{% highlight ruby %}

    excluded_substrings = %w(_with _suffix1)
    
    an_array.delete_if do |item|
      excluded_substrings.fuzzy_include?(item)
    end
    # => ["and_this"]

{% endhighlight %}

You can also provide a ["format"](http://www.ruby-doc.org/core-1.9.3/String.html#method-i-25)
(for lack of a better word) for the regular expression that will be used to
match items.

You could for example find if a given string ended in a number of suffixes.

{% highlight ruby %}

    excluded_substrings = %w(_with _this)
    
    an_array.delete_if do |item|
      excluded_substrings.fuzzy_include?(item, '%s$')
    end
    # => ["something_suffix1", "something_with_this_also"]

{% endhighlight %}

In this example, the second value `"something_with_this_also"` is not excluded
because it does not _end_ with `"_with"` as specified by the format `"%s$"`.

I must admit, something about this solution doesn't quite feel "right", but it
was at least a fun little experiment. Feel free to [tell me](mailto:ur@iamvery.com)
if you think I'm way out in left field over this solution. :)
