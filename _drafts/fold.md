---
layout: post
title: Visual Guide to Folding
tags:
- functional programming
- elixir
- ruby
---

You know folding.
You fold things everyday, clothes, paper, stacks of cash.

> **fold**:
> bend something over itself so that one part of it covers another

— Dictionary.app

Another way to think of folding is that it's the act of _combining_ two parts into one.
This precisely explains the role of `fold` in functional programming.
You `fold` lists to iteratively combine elements of the list into a new value.
Don't be confused, `fold` goes by many different names in various programming languages, both object-oriented and functional.

- `accumulate`(e.g. C++)
- `aggregate` (e.g. C#)
- `compress`
- `inject` (e.g. Ruby)
- `reduce` (e.g. Ruby)

A full listing of folding functions in various languages may be seen on [Wikipedia][wikipedia].

Despite the name, these functions all have the same basic behavior.
**They combine a collection by repeatedly applying some operation to its contents.**

## A Visual

Paper was mentioned as something you might fold.
In fact it makes a perfect practical example of programmatic folding.
Consider a piece of paper containing a collection of numbers.

![strip of paper with numbers on it](/img/blog/2016/05/strip.jpg)

To combine the numbers on the paper, you might fold each pair together from the left.

![gif of paper being folded from the left](/img/blog/2016/05/fold-from-left.gif)

Likewise, you might also fold them together from the right.

![gif of paper being folded from the right](/img/blog/2016/05/fold-from-right.gif)

For now, consider folding from the left.
In order to combine each pair of values, you must provide an operation to perform at each fold.
For example, to find the sum of some numbers you might fold the collection of numbers with addition.

![photo of strip with + added between numbers](/img/blog/2016/05/strip-with-addition.jpg)

With the addition operation inserted between each pair, you can fold the collection applying the operation at each step.

![gif of paper being folded and numbers being added](/img/blog/2016/05/fold-from-left-with-addition.gif)

Addition is a well-known operation that most folks are familiar with, but the operation used may be arbitrarily complex as long as it accepts two operands and returns a value compatible with the next fold.
It might even be a function itself.
Folding from the left with addition might resemble the following Elixir code.

```elixir
# Elixir
add = fn a,b -> a + b end
fold_left(add, 0, [1,2,3])
```

Now consider a different operation.
Instead of combining the collection together into a single number, the collection may be combined into a new collection.
This is often referred to as "mapping", i.e. mapping each value to a new value.
The operation used by such a fold might look like this Ruby code.

```ruby
# Ruby
double_shovel = ->(list, number) { list << number*2 }
fold_left(double_shovel, [], [1,2,3])
# => [2,4,6]
```

At each fold, the operation is applied to the last operation's result and the next element in the collection.
An initial value is provided to serve both as a starting point and as a default given an empty collection.

![gif of paper being folding and elements being doubled](/img/blog/2016/05/fold-from-left-with-map-double.gif)

## A Naive (Ruby) Implementation

Armed with your understanding of `fold`, it's time to implement a `fold_left` function.
Start with a method written in Ruby.

```ruby
def fold_left(operation, result, list)
  list.each do |item|
    result = operation.(result, item)
  end
  result
end

addition = ->(a,b){ a+b }
fold_left(addition, [1,2,3])
# => 6
```

## Recursion

The previous implementation is considered naive, because it requires an intermediate variable `result` which is repeatedly bound throughout the run.
Do not confuse naive with _wrong_.
The solution works, but may not be the most elegant.
More commonly fold is implemented using recursion.
Some might argue that it is even more readable that way.
Take a moment to refactor `fold_left` using recursion.

```diff
 def fold_left(operation, result, list)
-  list.each do |item|
-    result = operation.(result, item)
-  end
-  result
+  return result if list.empty?
+  head, *tail = list
+  fold_left(operation, operation.(initial, head), tail)
 end

 double_shovel = ->(l,n){ l << n*2 }
 fold_left(double_shovel, [], [1,2,3])
 # => [2,4,6]
 fold_left(double_shovel, [], [])
 # => []
```

This implementation recursively calls `fold_left` by applying the `operation` to each resulting value and the next element ("head") of the list.
If you're not familiar with Ruby's splat (`*`), in this case it isolates the first element of the array and "slurps" up the rest into a new array (`tail`).


[wikipedia]: https://en.wikipedia.org/wiki/Fold_(higher-order_function)
