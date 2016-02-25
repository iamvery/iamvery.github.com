---
layout: post
title: Usage Tests
---

Tests suites have a number of purposes.
Perhaps most commonly you think of the test suite as validating the behavior of your code.
Absolutely.
But they also serve as examples of using the lib.
Let's make that more explicit.

## Usage

If you have perused the test suites for library code, you may have noticed some conventions.
Folks tend to have a `units/` directory for unit (read: isolated) tests.
Other places you may see a `lib/` directory if the author is trying to keep the file to file organization the same between their implementation and tests.
Finally you may have seen an `integration/`, `acceptance/`, etc. directory that indicates tests of various pieces working together.
Sometimes the integration directory (whatever it be called) also has tests illustrating example usage of the lib.

Here's the thing.
Probably all non-trivial, well organized code will have interfaces that aren't meant to be used publicly.
Within a class we often mark methods as `private` to discourage external use.
You may even do the same thing [with internal classes][private-class].

Hard as you try, you will always have publicly _accessible_ interfaces that were never intended for external use.
Recently, I was [working on ActionCable][ac-pr] and a [suggestion] was made that we move the change closer to the library's user interface.
It became clear with that suggestion how difficult it is to discern what portion of ActionCable was intended to be used directly.
It's actually quite small.

So how do you communicate this to the reader.
Perhaps by organizing your test suite better.
Rather than having to dig through a ton of test files in numerous directories, make it explicit.

## usage_test.(rb|exs|js|java|etc)

Call it like it is.
If you're testing the usage of you library, it's a usage test.
You could call it whatever you want, examples, acceptance, etc.
The point is to communicate the intend, and to be honest if a convention is established that's recognizable everyone wins.
At a certain point, you're library is probably too big to test its usage in a single file (small files communicate intent).
Then create a `test/usage/` directory and write descriptive test files there.
All in the name of communicating intent.
Don't hesitate to drop a link in your readme pointing the reader to the usage tests for examples.

Here's a contrived example for a visual.

```
test
├── integration
│   └── foos_and_bars_working_together_test.rb
├── units
│   ├── bar_test.rb
│   └── foo_test.rb
└── usage
    └── using_the_lib_test.rb
```

## Who does this?

Interestingly in my limited research, it seems a number of libraries have a style something like this.
However I've never seen it formalized.
Examples include [adamantium], [anima], and probably a lot of other projects listed on [microrb].

I fully intend to give this a whirl with the next library code I write!
Will you write usage tests?


[private-class]: https://blog.arkency.com/2016/02/private-classes-in-ruby/
[ac-pr]: https://github.com/rails/rails/pull/23811
[suggestion]: https://github.com/rails/rails/pull/23811#issuecomment-187370696
[adamantium]: https://github.com/dkubb/adamantium/blob/master/spec/integration/adamantium_spec.rb
[anima]: https://github.com/mbj/anima/blob/master/spec/integration/simple_spec.rb
[microrb]: http://microrb.com/
