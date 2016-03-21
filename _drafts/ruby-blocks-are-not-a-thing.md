---
layout: post
title: Ruby Blocks Are Not a Thing
---

The other week [teaching Ruby at Big Nerd Ranch][bnr], I made a surprising (to me) discovery.
Turns out, Ruby blocks are not a thing.
That is, they're not an object.
They're syntax.
Allow me to explain...

## Blocks, Procs, and Lambdas

Anytime the subject of callables comes up in Ruby, you immediately think "ah yes, blocks, procs, and lambdas".
This paints the mental picture of 3 separate but equal concepts.
Not quite.
It's all procs.
Blocks are just Ruby syntax.

### Procs and Lambdas

When referencing callables, there are only procs, i.e. instances of the `Proc` class.
Lambdas are a special type of proc.
Specifically lambdas are a slightly more restrictive type of proc.
They exhibit two behaviors not found in regular procs.

1. Lambdas enforce arity
1. Lambdas have their own execution context

Quick! Let's remind ourselves what this means.

#### Arity

Lambdas raise an `ArgumentError` if the wrong number is given.

```ruby
l = lambda { |a, b| }
# => #<Proc:0x007f94fc386038@(irb):9 (lambda)>
l.call
# ArgumentError: wrong number of arguments (0 for 2)
```

Procs do not.

```ruby
p = proc { |a, b| puts "proc!" }
# => #<Proc:0x007f94fc237290@(irb):3>
p.call
# proc!
# => nil
```

#### Execution Context

Lambdas can explicitly return from their execution.

```ruby
def call_lambda
  value = lambda { return :ah_hah }.call
  puts value
  return :still_returned
end

call_lambda
# ah_hah
# => :still_returned
```

Procs return from the calling context.

```ruby
def call_proc
  proc { return :this_one }.call
  return :not_this_one
end

call_proc
# => :this_one
```

### Blocks

Turns out the stuff we refer to as blocks in Ruby are just the syntax for a special kind of argument that defines a sequence of statements.
These blocks are then used to carry out that operation at a later point.
Actually you've already used blocks several times in the above examples.
The methods `proc` and `lambda` require a block argument used to define their behavior.

In fact, when you use the explicit block syntax, `&block_arg` this block argument is used to initialize a `Proc` which may be called during the method's execution.
Let's illustrate this using [pry].

Consider this method with an explicit block argument.
```ruby
def foo(&b)
  binding.pry
end
```

```
[3] pry(main)> foo {}

From: (pry) @ line 4 Object#foo:

   3: def foo(&b)
=> 4:   binding.pry
   5: end

pry> b
=> #<Proc:0x007fb96aa3cd90@(pry):6>
```

There it is, a proc.
As far as I can tell the explicit block argument syntax `&b` is just sugar for `b = Proc.new`.
We can illustrate that with this method.

```ruby
def foo
  b = Proc.new
  b.call
end

foo { "orly" }
# => "orly"
```

The Ruby docs state that ["`Proc::new` may be called without a block only within a method with an attached block, in which case that block is converted to the Proc object"][docs].


Interestingly when you invoke the block argument using the `yield` method, Ruby is able to optimize the block call pretty significantly.
Check out [these benchmarks][slow-proc].

## Conclusion

So to answer the question "what is a Ruby block?".
It's just the _syntax_ for the special type of argument that is used to define some sequence of behavior.
The only way for you to interact "directly" with a block at all is with the `yield` method, but if you wish to pass them around you've got to convert it to a proc for reference.
And this [may be slow][slow-proc].


[bnr]: https://training.bignerdranch.com/classes/ruby-on-the-server
[pry]: https://github.com/pry/pry
[docs]: http://ruby-doc.org/core-2.3.0/Proc.html#method-c-new
[slow-proc]: http://mudge.name/2011/01/26/passing-blocks-in-ruby-without-block.html
