---
layout: post
author: Jay Hayes
title: No Date.today? It's DateTime!
categories:
- Ruby on Rails
---

In my [last post][swift-blog-post], I got all fluffy talking about love and
coffee and all that crap. Programming isn't all butterflies and rainbows, folks.
Eventually it will happen. You will have to deal with [time zones][tz-wikipedia].

![NOOOO]({{ site.baseurl }}/img/blog/2014/09/starwars-no.gif)

Learn from my mistakes.

## TL;DR

_Always_ parse user input time.

## Background

Not long ago, I was happily working away on client project when a feature came
along.

> time should also go Eastern US instead of UTC

They said.

"No problem," I thought. We'll configure the application's time zone to use
Eastern time and go on our merry way. Generally this is true, but there's a
big catch when you're taking user input time and throwing it against the
database.

## An Example

Let's set the stage. Pretend we have an app with a very simple
[data model][data-model-wikipedia]. It consists of a single model, `Plan`,
which has a single `datetime` attribute `going_out_at`.

### Our Goal

The goal is simple, we want users to be able to find plans to go out between
two points in time. How they enter this information is irrelevant, but we can
assume that the parameters will be parsable time strings.

### Our First Try

We create a range using the user input values and query the database.

```
> Plan.all
=> [#<Plan id: 1, going_out_at: "2014-09-25 09:39:30">]
> from = '2014-09-25 09:00'
> to = '2014-09-25 10:00'
> Plan.where(going_out_at: from..to)
  SELECT "plans".* FROM "plans" WHERE ("plans"."going_out_at" BETWEEN '2014-09-25 09:00' AND '2014-09-25 10:00')
=> [#<Plan id: 1, going_out_at: "2014-09-25 09:39:30">]
```

By default, Rails apps are configured to use the UTC time zone. This also
happens to be the time zone (or lack there of) the database stores things in.
Due to this coincidence, using the input times as strings works fine when sent
directly to the database. That is, they match the database's format and return
the expected results without having to cast the values. Unfortunately, the
database doesn't expect to be given zoned times in this query...

### Our Grand Disappointment

This is where we attempt to localize our app to our time zone. We whip out
`application.rb` and set the app's time zone.

```
config.time_zone = 'Eastern Time (US & Canada)'
```

With this configuration set, times in the app will be automatically localized
to the application's timezone.

```
> Plan.first.going_out_at
=> Thu, 25 Sep 2014 05:39:30 EDT -04:00
```

Now, let's have a look at the same scenario as above in Eastern US time.

You can see the date stored in the database is UTC:

```
> Plan.all
=> [#<Plan id: 1, going_out_at: "2014-09-25 09:39:30">]
```

The user inputs the following times which present 09:00-10:00 in UTC.

```
> from = '2014-09-25 05:00 -04:00'
> to = '2014-09-25 06:00 -04:00'
> Plan.where(going_out_at: from..to)
SELECT "plans".* FROM "plans" WHERE ("plans"."going_out_at" BETWEEN '2014-09-25 05:00 -04:00' AND '2014-09-25 06:00 -04:00')
=> []
```

As you can see, the query returns an empty set because the database doesn't
know to interpret these values as zoned times. Let's jump into the database to
prove our theory.

```
sqlite> SELECT "plans".* FROM "plans"
   ...> WHERE "plans"."going_out_at"
   ...> BETWEEN '2014-09-25 05:00 -04:00' AND '2014-09-25 06:00 -04:00';
# nothing here...
```

In order to query using zoned times, we must explicitly cast the times as the
`datetime` type.

```
sqlite> SELECT "plans".* FROM "plans"
   ...> WHERE "plans"."going_out_at"
   ...> BETWEEN datetime('2014-09-25 05:00 -04:00') AND datetime('2014-09-25 06:00 -04:00'));
1|2014-09-25 09:39:30.961636
```

So how do we fix this issue in our app? Do we need to cast these columns in our
query? Yuck...

### The Solution

Thanksfully the solution is relatively simple. Always deal in date and time
objects. This allows Rails to do the heavy lifting of making sure queries
get zoned in a way that is compatible with the database. Check it out.

```
> from_time = Time.zone.parse(from)
=> Thu, 25 Sep 2014 05:00:00 EDT -04:00
> to_time = Time.zone.parse(to)
=> Thu, 25 Sep 2014 06:00:00 EDT -04:00
> Plan.where(going_out_at: from_time..to_time)
SELECT "plans".* FROM "plans" WHERE ("plans"."going_out_at" BETWEEN '2014-09-25 09:00:00.000000' AND '2014-09-25 10:00:00.000000')
=> [#<Plan id: 1, going_out_at: "2014-09-25 09:39:30">]
```

You can see that when the range's values are zoned time, Rails takes care of
converting them to UTC for the database queries. Just make sure you
[parse using `Time.zone`][working-with-time]!

## Conclusion

Let's face it, [time is hard][time-zones-youtube]. Be vigilant and watch out
for these crazy time zone related quirks! I would love to hear about your
experience with localizing applications.

[swift-blog-post]: http://www.bignerdranch.com/blog/discover-swift-with-this-one-weird-rubyist
[tz-wikipedia]: http://en.wikipedia.org/wiki/Time_zone
[data-model-wikipedia]: http://en.wikipedia.org/wiki/Data_model
[time-zones-youtube]: https://www.youtube.com/watch?v=-5wpm-gesOY
[working-with-time]: http://www.elabs.se/blog/36-working-with-time-zones-in-ruby-on-rails
