---
layout: post
author: Jay Hayes
date: 2016-09-15 10:00:53+00:00
title: "Catching Strong Params Problems Early"
description: Rails' strong parameters protect apps from security risks, but can also make it tough to troubleshoot missing data. Learn to get better info from strong params.
excerpt: If only there was a way to have Rails raise an error when an unexpected parameter is encountered out by strong params... Actually, there totally is!
canonical: https://www.bignerdranch.com/blog/catching-strong-params-problems-early/
tags:
- big nerd ranch
- ruby
- rails
---

**TL;DR:** Use the `ActionController::Parameters.action_on_unpermitted_parameters` configuration to control the behavior of Rails' strong parameters.

Ruby on Rails developers, here's a scenario:

You're adding an attribute to a model in your application. You've done it all right:

- Written an acceptance test for your feature
- Created a migration to update the database schema
- Added new form input for the data in your view

However, when you run the test suite, the test fails.
But how can that be? You're an experienced Rails developer. This is basic stuff!

The test output isn't very helpful either:

> Expected page to contain [new attribute data], but it didn't.

After double-checking your test, the last resort is firing up the application and trying it out in the browser yourself. Confirmed, the form is set up correctly, elements are named as they should be. You fill it out and submit it. It all works, but why isn't the model being updated?! Time passes, you've debugged here and pry'd there. Then it suddenly hits you.
The new parameter was not permitted with strong params!

![Khan](/img/blog/2016/09/khan.jpg "Khan")

Has this ever tripped you up?
It gets me _all_ the time, and I [teach this stuff][class].
If only there was a way to have Rails raise an error when an unexpected parameter is encountered out by strong params...
Actually, there totally is!

## Configuration

Rails provides a small bit of configuration to control the behavior of strong params for unexpected parameters.
`ActionController::Parameters.action_on_unpermitted_parameters`.
The default behavior is to `:log` the occurrence and move along.
However, another option is to `:raise` an error.
Perfect.

Take a moment to experiment with this option.

```ruby
irb> ActionController::Parameters.new(name: "Jay", age: 29).permit(:name).to_h
=> {"name"=>"Jay"}
irb> ActionController::Parameters.action_on_unpermitted_parameters = :raise
=> :raise
irb> ActionController::Parameters.new(name: "Jay", age: 29).permit(:name).to_h
ActionController::UnpermittedParameters: found unpermitted parameter: age
```

That is exactly the behavior you want from your app! Create a configuration file for strong params.

```ruby
# config/initializers/strong_params.rb
if Rails.env.test?
  ActionController::Parameters.action_on_unpermitted_parameters = :raise
end
```

With that configuration loaded, Rails will now raise an exception in your test environment any time an unpermitted parameter is encountered.

A timely error reminds you that you must permit parameters, rather than wasting time realizing that parameters are being quietly stripped from the request.
For more information see [the documentation][docs].

## Back to Work

Does this tip resonate with you? Do you have an alternative method of avoiding this common pitfall while building apps? Let us know what you think!

[class]: https://training.bignerdranch.com/classes/ruby-on-rails
[docs]: http://api.rubyonrails.org/classes/ActionController/Parameters.html
