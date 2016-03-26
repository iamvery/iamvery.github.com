---
layout: post
title: Isolated Tests
tags:
- ruby
- testing
---

Testing interfaces in isolation leads to good software design.
Coupling becomes glaringly obvious when mocks and stubs get out of hand.
You may have heard this called unit testing, but [not everyone agrees that implies isolation][fowler-unit-tests].
Names are important, but let's not get caught up in terminology.
The real benefit of isolated in tests is the affect it has on design.

Consider a duck.

{% highlight ruby linenos %}
{% include code/isolated_tests/naive/duck.rb %}
{% endhighlight %}

To test that the duck can speak, you would have try one of:

1. Mock stdout and assert that `puts` is called with the expected value.
1. Temporarily capture stdout and assert on it's value.

Have a look at both of these options.

#### Mocking stdout

{% highlight ruby linenos %}
{% include code/isolated_tests/naive/mock_stdout.rb %}
{% endhighlight %}

#### Capturing stdout

{% highlight ruby linenos %}
{% include code/isolated_tests/naive/capture_stdout.rb %}
{% endhighlight %}

At a cursory glance, you might side with the first option.
It's less code.
Regardless, the fact is a passing test implies "a duck quacks".

## An Important Distinction

Testing that a duck _quacks_ is more than testing that a duck _speaks_.
It is interesting to consider that if you change what a speaking duck "sounds like" the failing test implies that a duck can no longer speak.
Said differently, **altering the perception of quacking destroys our understanding of the duck.**

Additionally, as illustrated by the second test implementation, our duck is coupled tightly to standard output.

## Refactor

Both of these concerns may be addresses by applying the Single Responsibility Principal.
First, identify the responsibilities:

* a duck speaks
* a quack sounds quacky

Now that you recognize a quack as having responsibility of its own, it's easy to imagine it being an object.
Below we implement `Quack` with an injectable interface for IO.
This allows us to test the quack itself in isolation.

{% highlight ruby linenos %}
{% include code/isolated_tests/refactored/quack.rb %}
{% endhighlight %}

With this new concept realized, it's easy to imagine giving the duck a voice.

{% highlight ruby linenos %}
{% include code/isolated_tests/refactored/duck.rb %}
{% endhighlight %}

Testing that a duck speaks is just a matter of making sure that it utters its voice.
This frees you to change what it means to utter a quack without affecting the the means the duck uses to speak.

## Integration

Of course these tests do _not_ ensure that a duck actually quacks.
Such would be done with an integration test that gives you confidence in the collaboration between objects in your system.

**Isolated tests free you to refactor and encourage flexible software design.**

Maybe you never considered a duck quacking to a file.
Well now it's nbd.

{% highlight ruby linenos %}
quackings = File.open("quackings", "w")
Duck.new(voice: Quack.new(io: quackings))
{% endhighlight %}

[fowler-unit-tests]: http://martinfowler.com/bliki/UnitTest.html
