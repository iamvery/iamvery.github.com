---
layout: post
title: Method Chaining is Composition
---

Have you ever chained several method invocations together in a single statement?
You may not have thought about it, but this is composition!

## An Example

Take this Ruby example.

```ruby
# methodchain.rb
"foo bar".upcase.split
=> ["FOO", "BAR"]
```

In essence, the result of everything to the left of the "dots" is the subject of the methods on the right.
Let's have a little fun and write this out in a more traditional (not idiomatic) composition sense, i.e. `foo(bar(_))`.

```ruby
# composition.rb
upcase = ->(s){ s.upcase }
split = ->(s){ s.split }

split.(upcase.("foo bar"))
=> ["FOO", "BAR"]
```

That's harder to read.
You have to read it from the inside out.
This is exactly why functional programming languages often have a "pipe" operator.
Here's an example of Elixir's pipe, `|>`.

```elixir
# pipe.exs
"foo bar" |> String.upcase |> String.split
=> ["FOO", "BAR"]
```

It's harder to read the composition when there is more than one function being called.

```elixir
# composition.exs
String.split(String.upcase("foo bar"))
=> ["FOO", "BAR"]
```

You might notice this is actually very similar in structure to the original Ruby "dot" example.
You could even import the `String` functions to eliminate some noise.

```elixir
import String

"foo bar" |> upcase |> split
=> ["FOO", "BAR"]
```

While you're having so much fun, hack Ruby to add a "pipe" operator.

```ruby
class Object
  def >>(proc)
    proc.(self)
  end
end
```

The `Object` class is reopened and a method `>>` is implemented.
This will be Ruby's "pipe".
The operation is straight forward.
When piping, the right-hand side must be callable.
Let's see an example of it in action with our second Ruby example.

```ruby
"foo bar" >> upcase >> split
=> ["FOO", "BAR"]
```

Now that _does_ look like the Elixir code!
This works because all objects (including the string `"foo bar"`) will now implement the `>>` method.

Is this useful?
Maybe, maybe not, but it's an interesting thought experiment to think of chained method calls as the composition of multiple method executions.
The inverse is also interesting.
That is since Elixir's `|>` operator passes along the left-hand side as the first argument to the right hand side, those functions are being "called on" the left hand side.
Many Elixir functions are implemented so that the "subject" of the function is the first argument for this very reason!
