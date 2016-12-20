---
layout: post
title: "Composing Elixir Functions"
description: Learn how to Elixir can be extended to build complex functions out of simpler ones.
excerpt: Function composition is a technique used to build complex functions out of simpler ones. Elixir does not provide a mechanism for composing two functions into a new function. Let's play with that a little and see what can be done.
canonical: https://www.bignerdranch.com/blog/composing-elixir-functions/
tags:
- elixir
---
[Function composition][fun-comp-wiki] is a technique used to build complex functions out of simpler ones. Elixir does not provide a mechanism for composing two functions into a new function. Let's play with that a little and see what can be done.

## An Example

Say using Elixir you want a function that appends an element to a list. An efficient way to do this is by first reversing the list, then _prepending_ the element, and finally reversing the list again.

Kick things off by manually implementing `append` in terms of reversal and prepending:

```elixir
iex> append = fn list, item ->
  list = Enum.reverse(list)
  list = [item|list]
  Enum.reverse(list)
end
#Function<...>
iex> append.([1,2,3], 4)
[1, 2, 3, 4]
```

This certainly gets the job done, but perhaps it could be even more to the point. The main problem is the implementation shifts the focus from the operations to state management. The `list` variable is introduced and repeatedly referenced (5 times!) during the execution of the function. As [Josh][josh] points out in his [decomposition blog][decomp], Elixir provides a mechanism for composing function applications with its pipe `|>` operator. Refactor it with pipes:

```elixir
iex> prepend = &[&2|&1]
#Function<...>
iex> append = fn list, item ->
  list
  |> Enum.reverse
  |> prepend.(item)
  |> Enum.reverse
end
#Function<...>
iex> append.([1,2,3], 4)
[1, 2, 3, 4]
```

That does seem quite a bit better (idiomatic, even)! You no longer repeatly refer to `list`, and the implementation is more clearly composed of `prepend/2` between calls to `reverse/1`. Even so, the state management is still present in the form of arguments. Is there an implementation that's even more clearly composed of the operations? What if you could compose the existing functions together into a new `append` function?

Elixir does not provide such an operation, but imagine a custom infix operator, `<|>`, for composing functions:

```elixir
iex> append = reverse <|> prepend <|> reverse
#Function<...>
```

Such an `append` function would, in effect, capture the expression `reverse(prepend(reverse(list), item))`, requiring the arguments `list` and `item` in that order.

## Compose

To arrive at the final implementation, start by implementing a `compose/2` function using recursion. First define the base case:

```elixir
defmodule Compose do
  def compose(f, arg) do
    f.(arg)
  end
end
```

This base case effectively _applies_ the `arg` to the function `f`. For example:

```elixir
iex> double = fn n -> n*2 end
#Function<...>
iex> Compose.compose(double, 4)
8
```

Next add an implementation of `compose/2` that recurses when the second argument is a function:

```elixir
defmodule Compose do
  def compose(f, g) when is_function(g) do
    fn arg -> compose(f, g.(arg)) end
  end

  def compose(f, arg) do
    f.(arg)
  end
end
```

This version of `compose/2` returns a function that applies its argument to `g` and then composes the result with `f`. However, at this point the implementation works only to compose functions that accept a single argument, i.e. having an arity of 1:

```elixir
iex> reverse_sort = Compose.compose(&Enum.reverse/1, &Enum.sort/1)
#Function<...>
iex> reverse_sort.([3,1,2])
[3, 2, 1]
```

It does not work for functions requiring many arguments (N-arity):

```elixir
iex> reverse_prepend = Compose.compose(&[&2|&1], &Enum.reverse/1)
#Function<...>
iex> reverse_prepend.([1,2,3])
** (BadArityError)
```

The error happens, because `compose/2` only ever applies one argument, i.e. `.(arg)`. Elixir is strict about the arity of functions. For `compose/2` to work with N-arity functions, you need some way to apply a variable number of arguments.

### Arguments

A solution to this problem is changing how N-artiy functions are applied. Since there is no way to anticipate how many arguments will be needed, you can instead rearrange the function to support multiple single-argument applications until all have been provided. This is a common functional programming technique known as _currying_.

Currying converts a function of arity _N_ into a function of 1-arity that when applied _N_ times produces the result. Consider this example of manual currying with nested functions:

```elixir
iex> add = fn a -> fn b -> a+b end end
#Function<...>
iex> add_one = add.(1)
#Function<...>
iex> add_one.(2)
3
```

The function `add` is defined to return another function. The result of applying the value `1` to `add` returns a function that accepts the second argument for the addition. This idea of applying only part of what a function needs to return a result is called _partial application_. The partial application of `add` with `1` is a function that "adds one". Once all the arguments have been applied, the result is returned:

```elixir
iex> add.(2)
#Function<...> # a function that "adds 2"
iex> add.(2).(3)
5
```

Notably, this mechanism is not built into Elixir, but there are [packages][curry-pkg] that add the behavior as well as a [great post on currying in Elixir][elixir-curry]. For the remainder of this post, it's assumed you have a module `Curry` that includes a function `curry/1` such that you can:

```elixir
iex> add = Curry.curry(fn a,b -> a+b end)
#Function<...>
iex> add.(2).(5)
7
```

### Finishing `compose/2`

As you have learned, currying is a solution to your variable argument problem. It also happens to fit really well into the recursion that is already set up in `compose/2`. Update the implementation to curry both functions passed in:

```diff
 defmodule Compose do
+  import Curry
+
   def compose(f, g) when is_function(g) do
-    fn arg -> compose(f, g.(arg)) end
+    fn arg -> compose(curry(f), curry(g).(arg)) end
   end

   def compose(f, arg) do
     f.(arg)
   end
 end
```

It might be surprising to realize this is the only change needed to complete the implemetnation! The recursive definition of `compose/2` applies arguments one at a time to the composed function until a result is found, and then then applies that result to the outer function in the base case. See if it fixed your arity error:

```elixir
iex> reverse_prepend = compose(&[&2|&1], &Enum.reverse/1)
#Function<...>
iex> reverse_prepend.([1,2,3]).(4)
[4, 3, 2, 1]
```

Nice! Notice that each successive argument is a partial application to the underlying curried functions. The really cool thing is that the order of the arguments called on `reverse_prepend` matches the order of respective arguments to each composed function; the list first, then the prepended item.

### Custom Operator

For convenience, complete your implementation of `Compose` with a custom infix composition operator, `<|>`:

```elixir
defmodule Compose do
  import Curry
  def f <|> g, do: compose(f, g)
  ...
end
```

That's it! Now by importing `Compose`, functions may be composed together with `<|>`:

```
iex> import Compose
Compose
iex> square = fn n -> n*n end
#Function<...>
iex> fourth = square <|> square
#Function<...>
iex> fourth.(2)
16
```

## `append`

Tie up this experiment by returning to the original task. Recall, you want to define a function `append` in terms of `reverse` and `prepend`. The implementation with function composition is now purely expressed as operations:

```elixir
iex> reverse = &Enum.reverse/1
#Function<...>
iex> prepend = &[&2|&1]
#Function<...>
iex> append = reverse <|> prepend <|> reverse
#Function<...>
iex> append.([1,2,3]).(4)
[1, 2, 3, 4]
```

## Mathy Conclusion

One important note is that the Elixir implementation demonstrated is not _pure_ function composition in the mathematical sense. Function composition requires that function signatures match exactly in order to be compatible for composition. No such restrictions exist in this implementation. In fact it displays the interesting property of _trickling_ arguments down in order until each composed function is fully applied. Elixir is a dynamically typed language, and as such it allows a lot of flexibility in how functions are defined and applied to. Have fun!

[fun-comp-wiki]: https://en.wikipedia.org/wiki/Function_composition_(computer_science)

[josh]: https://www.bignerdranch.com/about-us/nerds/josh-justice/
[decomp]: https://www.bignerdranch.com/blog/breaking-up-is-hard-to-do-how-to-decompose-your-code/
[curry-pkg]: https://hex.pm/packages?search=curry&amp;sort=downloads
[elixir-curry]: http://blog.patrikstorm.com/function-currying-in-elixir
