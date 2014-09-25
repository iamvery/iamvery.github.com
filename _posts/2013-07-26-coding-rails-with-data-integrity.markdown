---
author: Jay Hayes
date: 2013-07-26 17:16:35+00:00
layout: post
title: Coding Rails with Data Integrity, Part 1
wordpress_id: 3340
categories:
- Ruby on Rails
---

Originally posted on the [Big Nerd Ranch Blog](http://www.bignerdranch.com/blog/coding-rails-with-data-integrity).

---

Ruby and Rails gives us tools to quickly create powerful web applications. With little effort we are able to model our domain objects and build relationships between them. When it all boils down our apps aren't really interesting without data, and it is _supremely_ important that we ensure our data is safe, consistent and reliable. We can dramatically increase these factors by taking full advantage of the tools at hand. I want to tell you about some of these tools.


## Database Constraints


Most Ruby on Rails developers are fully aware of the features we're given in migrations to [add](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html#method-i-column) [constraints](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index) to the database, but I've found that few people take full advantage of them. Let's touch on a couple.


### A Boolean Example


Consider the following contrived example:

{% highlight ruby %}
class CreateWidgets < ActiveRecord::Migration
  def change
    create_table :widgets do |t|
      t.boolean :cool
    end
  end
end
{% endhighlight %}


This creates a `widgets` table with a `cool` boolean attribute. Assume we have an appropriate `Widget` ActiveRecord model. What's the big deal? Subtly this creates a boolean attribute that has _three possible states_ (`true`, `false` and `nil`). Does that matter? You can still do stuff like this:


{% highlight ruby %}
w = Widget.new
w.cool  # => nil
w.cool? # => false, nil is falsey
{% endhighlight %}


It works as expected, right? What if you wanted to query for uncool widgets? Unfortunately, we can't assume uncool widgets are widgets whose `cool` attribute is `false`. Check it out:


{% highlight ruby %}
Widget.create                # => #<Widget...>
Widget.count                 # => 1
Widget.where(cool: false)    # => [], doh
Widget.where.not(cool: true) # => [], Rails 4 only, also WAH!?!?!?
{% endhighlight %}


So how do we get uncool widgets?


{% highlight ruby %}
Widget.where('cool = ? OR cool IS NULL', false) # => [#<Widget...>]
{% endhighlight %}


Yeah... no. It's really not cool (sorry) to have to bring SQL to the table (*rimshot*) for what should be such a simple operation. The idea is that something is either cool or it isn't. Let's forget null as an option and make this a _boolean_. It can easily be remedied by adding some constraints to the `cool` column:


{% highlight ruby %}
class CreateWidgets < ActiveRecord::Migration
  def change
    create_table :widgets do |t|
      t.boolean :cool, null: false, default: false
    end
  end
end
{% endhighlight %}


Now the database will not allow a null value for the `cool` column. Further, this automatically sets the value to `false` when missing which probably makes a lot of sense. We should mention that sometimes it is desirable to allow null values as [sentinels](http://en.wikipedia.org/wiki/Sentinel_value). That's why we're given the option, but the decision is up to you!


### Adding Constraints to Existing Tables


It can be tricky to add these types of constraints to existing tables when there isn't a default value. There may be columns in your database that could benefit from null constraints, but how can we be sure that adding the constraint in a migration won't fail on existing records with null values? Try this:

{% highlight ruby %}
# Assume widgets have a `foo` string column with no constraints
class AddNullConstraintToWidgetFoo < ActiveRecord::Migration
  MISSING_VALUE_PLACEHOLDER = '<missing>'

  def up
    change_column_null :widgets, :foo, false, MISSING_VALUE_PLACEHOLDER
  end

  def down
    change_column_null :widgets, :foo, true
    execute "UPDATE widgets SET foo = NULL WHERE foo = #{MISSING_VALUE_PLACEHOLDER}"
  end
  # You always code your migration to rollback, right?
end
{% endhighlight %}


First, we set any existing null column to some known value. This value can be used in future queries to find records with formerly "missing" values. Now all columns will satisfy the newly added null constraint.


## OMG Validations!




> "WUT ABUT ACTIVEMODEL VALIDAYSHUNZ, OMG THEIR GR8!"


Agreed, I love 'em. But they're not for data integrity. They're best used to provide helpful feedback to users entering data into your app.

For the longest time, I put validations on _every_ attribute to match 1:1 with the database constraints. In general, this is redundant. The key is to validate attributes that your users will be interacting with. For example, you almost never have a user entering "mapping" records (think: join tables) manually... so don't validate presence of those `id`s! The database will make sure you don't get null values into those records. Trust the database; it's really good at what it does.



## Until next time...


Hopefully this provides some perspective on data integrity, and how it can improve your Rails app. We don't have to be DBAs to do this stuff, and it really can make our lives happier. Stay tuned: in future posts I hope to tackle uniqueness, referential integrity and more.



* * *





## Other Posts






  * [Coding Rails with Data Integrity, Part 1]({{ site.baseurl }}/blog/coding-rails-with-data-integrity) (null constraints and default values)


  * [Coding Rails with Data Integrity, Part 2]({{ site.baseurl }}/blog/coding-rails-with-data-integrity-part-2) (uniquness constraints)



What other ways have you come up with to ensure data integrity in your apps? We'd love to hear what you think!
