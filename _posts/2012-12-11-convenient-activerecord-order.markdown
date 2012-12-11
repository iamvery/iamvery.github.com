---
layout: post
title: Convenient ActiveRecord ordering
---

> **TL;DR**: My gem [https://github.com/iamvery/order](https://github.com/iamvery/order) may make your life better!

Ordering records with ActiveRecord has always felt a bit weird to me. Its nearly
the only simple circumstance I find myself in where I must write a short SQL
string. Today I released a simple little gem called [order](https://github.com/iamvery/order)
that attempts to address that issue by abstracting the definition of orderings into
a simple DSL.

Check out this example model:

{% highlight ruby %}
Person < ActiveRecord::Base
  orderable :first_name, :last_name
end
{% endhighlight %}

You can get ordered records like this:

    Person.order_by_first_name
    => SELECT "people".* FROM "people" ORDER BY "first_name" ASC

The library will also let you get results in descending order, specify orderings
with aliased names on multiple columns, and define custom ordering stratgies
using a block. Check out the README!

The last cool thing about this library is the `order_by` method. This lets you 
specify multiple ordering using a specially formatted string. This is 
particulary useful with controller parameters.

    Person.order_by('age, blood_type.desc, name')

Imagine that ordering being appended to a URL:

    /people?order=age,blood_type.desc,name

+1 for API ordering support!

Check it out at [https://github.com/iamvery/order](https://github.com/iamvery/order) and let me know what you think!

_By the way... how was "order" not already a gem?!_

