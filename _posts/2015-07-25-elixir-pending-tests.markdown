---
layout: post
title: Elixir Pending Tests
description: A quick post illustrating how easy it is to temporarily skip tests in Elixir.
tags:
- elixir
- testing
---

**Update**: This is now [built into Elixir](https://github.com/elixir-lang/elixir/commit/65f81054aa53b31e16ffb439dd6dfbf67265708d).

---

Recently I've been playing with [Elixir][elixir] in my spare time.
It's a dynamic, functional programming language built atop the [Erlang][erlang] virtual machine.
I try to practice [TDD][tdd] when writing software to encourage flexible designs.
One habit of mine is writing out many tests early about how I imagine a thing to work.
Of course all these tests fail initially which can be overwhelming when run together.
It's much more desirable to focus on one failing test at a time throughout the [red, green, refactor][rgr] process.

Elixir's [`mix` script][elixir-mix] is a neat little tool to create, manage, and test your Elixir projects.
By default, `mix` runs tests with the built-in [`ExUnit`][exunit] module.
This module is intentionally designed to be very basic, providing a small API for testing your programs.
While the ability to mark tests as pending is not immediately clear, it's easy to pull off.

## Module Attributes

This construct in Elixir is used for:

* annotation
* constant definition
* temporary storage

In ExUnit the `@tag` annotation can be used to add metadata to tests.
If you have used [RSpec][rspec], this is very similar to the hash passed as an optional second argument to `describe`, `it`, etc.

## Skip Tests

So we'll tag our ExUnit tests and skip them until we're ready to test the interface!

{% highlight elixir %}
@tag :skip
test "one of the things" do
  # ...
end
{% endhighlight %}

To run the test suite and skip these tagged tests, we can provide the `--exclude` option to `mix test`

{% highlight bash %}
$ mix test --exclude skip
{% endhighlight %}

## Configure ExUnit

To take things one step further, it would be nice if we didn't have to use a command line option every time we wanted to skip tests.
We can accomplish this by configuring ExUnit to exclude the `:skip` tag everytime.

Open `test/test_helper.exs` in your Elixir project and add the following:

{% highlight diff %}
+ExUnit.configure(exclude: [skip: true])
 ExUnit.start()
{% endhighlight %}

Now every time you run your test suite "skipped" tests are excluded! 💫

I'm having a lot of fun with Elixir.
Do you have any other invaluable tricks? Please share!

[elixir]: http://elixir-lang.org/
[erlang]: http://www.erlang.org/
[tdd]: https://en.wikipedia.org/wiki/Test-driven_development
[rgr]: http://www.jamesshore.com/Blog/Red-Green-Refactor.html
[elixir-mix]: http://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html
[exunit]: http://elixir-lang.org/docs/v1.0/ex_unit/ExUnit.html
[rspec]: https://github.com/rspec/rspec
