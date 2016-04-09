---
layout: post
title: Ruby Argument Destructuring
tags:
- ruby
---

**TL;DR** You can use Ruby destructuring and the splat operator (`*`) to
simulate basic pattern matching.

You can do this when assigning variables:

```ruby
first, *, last = [1,2,3,4]
puts first, last
# 1
# 4
```

You can do this with procs and lambdas:

```ruby
foo = ->(_, (first, * last), _) { puts first, last }
foo.call(1, [2,3,4], 5)
# 2
# 4
```

And you can do this with methods:

```ruby
def foo(_, (first, *, last), _)
  puts first, last
end
foo(1, [2,3,4], 5)
# 2
# 4
```

Neat!
