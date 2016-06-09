---
layout: post
title: When to Parallel Map
tags:
- functional programming
- elixir
---

In his book, [Programming Elixir][prog-ex], Dave Thomas referrs to the parallel map function as the "hello world of Erlang".
It is a fun problem to solve!
The premise is relatively simple, the operation performed on each element is done in separate processes.
This allows the work to be done in parallel on the collection.
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

Therefore...

Use parallel if:
> sum(cost of operations) **>** cost of iteration + cost of processes

Otherwise, use regular map.

Put more succinctly, parallel map is a good fit if the operation being performed on each element is slow.

Here's a benchmark in Elixir.

<script src="http://gist-it.appspot.com/http://github.com/iamvery/elixir-parallel-mapping/blob/master/samples/maps.exs"></script>

And the results:

```
● master ~/Code/OSS/parallel » mix run samples/maps.exs
Benchmarking quick pmap...
Benchmarking quick map...

Name                          ips            average        deviation      median
quick map                     23093.24       43.30μs        (±19.05%)      41.00μs
quick pmap                    140.88         7098.46μs      (±16.30%)      6926.00μs

Comparison:
quick map                     23093.24
quick pmap                    140.88          - 163.93x slower

Benchmarking slow pmap...
Benchmarking slow map...

Name                          ips            average        deviation      median
slow pmap                     78.93          12668.78μs     (±9.53%)       12592.50μs
slow map                      0.50           2000475.00μs   (±0.02%)       2000475.00μs

Comparison:
slow pmap                     78.93
slow map                      0.50            - 157.91x slower
```

Slow operation, parallel map wins. Fast operation, regular map wins.


[prog-ex]: https://pragprog.com/book/elixir/programming-elixir
[nl-pmap]: http://nathanmlong.com/2014/07/pmap-in-elixir/
