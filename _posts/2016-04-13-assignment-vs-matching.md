---
layout: post
title: "Assignment vs. Matching"
excerpt: "A brief explanation of assignment and (pattern) matching."
tags:
- ruby
- elixir
---

A question came up in Slack today:

> I liked pattern matching better back when it was called method signatures.
> (Which is really a hyper-trolling way to ask what the difference is, lazyweb style ;-))

### It's not just for arguments

Matching goes beyond function definitions.
It can be thought of as an alternative to assignment.
In many functional programming languages, `=` is called the match operator.
Instead of assigning values on the right to variables on the left, each side is matched and any unbound variables are bound during matching.

As such structures of data are fair game for matching.
This is called pattern matching, i.e. matching the pattern of a data structure on each side of the operator.
Like assignment-oriented languages using assignment to initialize method arguments, match-oriented languages use matching to initialize function arguments.

### Programming Patterns

There are many programming patterns that emerge from this, but one example is error handling.
In Ruby we might do something like.

```ruby
def foo(asplode)
  fail "boom" if asplode
end

begin
  foo(true)
rescue
  puts "it asploded"
end
```

Where a language like Elixir with matching, it’s more common to do something like.

```elixir
def foo(asplode) do
  if asplode
    :ok
  else
    {:error, "boom"}
  end
end

case foo(true)
  :ok -> IO.puts "cool"
  {:error, msg} -> IO.puts msg
end
```

FWIW, Elixir has exceptions too fwiw http://elixir-lang.org/getting-started/try-catch-and-rescue.html, but it wouldn't be considered idiomatic.
