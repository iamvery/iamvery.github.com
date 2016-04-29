---
layout: post
title: Folding Elixir
tags:
- elixir
---

In functional programming, "folding" is something of a building block of other operations you may be familiar with, such as `map` and `filter`.
Folding can be done from the left and from the right.
Choosing the best direction depends on the problem you're solving.

## Folding Addition

For simple operations, like addition, it doesn't really matter which direction you go.
Addition is an associative operation, and folding on addition is reducing a collection down to a single value, so the direction we chose only affects the order the values are combined in.
For example, a right fold of addition would look something like this.

```
# add_foldr(0, [1,2,3])
(1 + (2 + (3 + 0)))
```

And from the left.

```
# add_foldl(0, [1,2,3])
(((0 + 1) + 2) + 3)
```

There are essentially two differences.

1. The side that folding proceeds from.
1. The element that is combined with the initial (`0` in this case) value.

So you might imagine an implementation of `add_foldr` and `add_foldl` looks something like this.

```
add_foldr(initial, [first|rest]) = first + foldr(initial, rest)
add_foldl(initial, [first|rest]) = foldl(initial + first, rest)
```

These implementations are limited to addition which cripples the power of folding, so here's another implementation that accepts a generic binary operation (`op`).

```
foldr(op, initial, [first|rest]) = first op foldr(initial, rest)
foldl(op, initial, [first|rest]) = foldl(initial op first, rest)
```

That's enough talking in abstract.
It's time to see some real code.
Check out this Elixir implementation of `foldr` and `foldl`.

## Elixir Folds

```elixir
defmodule Folds do
  def foldr(_, v, []), do: v
  def foldr(f, v, [x|xs]) do
    f.(x, foldr(f, v, xs))
  end

  def foldl(_, v, []), do: v
  def foldl(f, v, [x|xs]) do
    foldl(f, f.(v, x), xs)
  end
end
```

Take a moment to study this.
You should be able to see that it's very similar to the above pseudocode.
Both functions define a base case when the list is empty that returns the initial value (`v`).
The recursive case contains the difference.

## Mapping with Fold

So you may be asking yourself when it will matter which direction you fold.
Take the mapping operation as an example.
Start by defining right and left versions of map/2.

```elixir
def mapr(list, f) do
  mapper = fn item, rest -> [f.(item)|rest] end
  foldr(mapper, [], list)
end

def mapl(list, f) do
  mapper = fn list, item -> list ++ [f.(item)] end
  foldl(mapper, [], list)
end
```

Both implementations define a mapper function and pass it along to their corresponding fold.
You should notice that the mapper from the right can take advantage of the cons(truct) operation (`[head|tail]`).
The mapper from the left cannot use cons because the elements are evaluated in the opposite order.
Instead list concatenation must be used.
Unfortunately concatenation is demonstrably slower than cons.
Here's a benchmark of the above code.

```
● master ~/Code/OSS/folding_elixir » mix bench
Settings:
  duration:      1.0 s

## MapBench
[20:15:50] 1/2: mapping via foldr
[20:15:54] 2/2: mapping via foldl

Finished in 5.57 seconds

## MapBench
mapping via foldr        5000   649.56 µs/op
mapping via foldl           5   263533.40 µs/op
```

The benchmark maps over a list of 10,000 elements.
The results show that `mapr` was able to iterate 5000 times during the duration of the test, and each iteration took only a few hundred microseconds.
In contract, the `mapl` function was only able to iterate 5 times, and each iteration took about 400x longer to execute!

As you can see, implementing map/2 in terms of folding from the left, is a _significantly_ slower operation than the opposite, and this is to do with how lists work in Elixir.

The keen reader may have recognized an opportunity to optimize `mapl`.
The function could be implemented with cons, however the result of the fold would be in reverse order.
Since lists in Elixir are implemented as a linked list, reversing them is a very inexpensive operation.
As it turns out, doing this significantly improves the speed of mapping from the left.

```elixir
def maplr(list, f) do
  mapper = fn list, item -> [f.(item)|list] end
  foldl(mapper, [], list) |> Enum.reverse
end
```

And the benchmark results.

```
mapping via foldl and reversing        5000   695.76 µs/op
```

Quite close to the mapping from the right!
However, this implementation is no longer implemented in terms of _just_ folding.

If you're interested in the code used above, it's [available on Github](https://github.com/iamvery/folding_elixir).
