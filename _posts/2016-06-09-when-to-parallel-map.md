---
layout: post
title: When to parallel map
tags:
- functional programming
---

In his book, [Programming Elixir][prog-ex], Dave Thomas referrs to the parallel map function as the "hello world of Erlang".
It is a fun problem to solve!
The premise is relatively simple, the operation performed on each element is done in separate processes.
This allows the work to potentially be done in parallel on the collection.
If you're interested in an exmaple, check out my friend [Nathan Long's post][nl-pmap]

So why would you want to map over a collection in parallel?
The answer is usually "it's FASSSST!"
Yes, but when?
The bottleneck that parallel map addresses is the serial nature of the traditional map operation.
Each element is evaluated in serial and the operation is applied.
If the operation is slow, then the map operation can be significantly sped up by running them in parallel.
However, as with all optimizations there is a tax.
In the case of parallel map there are two taxes:

1. the overhead of creating and communicating with processes
1. two iterations through the list (one to start processes, one to get results)


[prog-ex]: https://pragprog.com/book/elixir/programming-elixir
[nl-pmap]: http://nathanmlong.com/2014/07/pmap-in-elixir/
