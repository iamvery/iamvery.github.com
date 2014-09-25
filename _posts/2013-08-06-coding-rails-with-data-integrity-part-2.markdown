---
author: Jay Hayes
date: 2013-08-06 21:43:08+00:00
layout: post
title: Coding Rails with Data Integrity, Part 2
wordpress_id: 3421
categories:
- Ruby on Rails
---

Originally posted on the [Big Nerd Ranch Blog](http://www.bignerdranch.com/blog/coding-rails-with-data-integrity-part-2).

---

[Last time]({{ site.baseurl }}/blog/coding-rails-with-data-integrity), we discussed how database [null constraints](http://www.w3schools.com/sql/sql_notnull.asp) and [default values](http://www.w3schools.com/sql/sql_default.asp) can increase confidence in your app's data.

This time, I want to take a look at [uniqueness constraints](http://www.w3schools.com/sql/sql_unique.asp). Rails provides uniqueness validations, but as we learned in the previous post, validations aren't necessarily the right tool to ensure data integrity. And Rails' uniqueness validation in particular is not without [its perils](http://robots.thoughtbot.com/post/55689359336/the-perils-of-uniqueness-validations).


## Uniqueness by Example


Eventually you'll realize that correctness demands certain data be unique. One of the most common examples for a uniqueness constraint is for users. If you allowed multiple users to have the same email address or username, users would be indistinguishable. Such information serves as identification for individuals.This example has been driven into the ground, so let's talk about something more interesting.


### Team Membership


Consider an app that has teams and users. Say we want users to be a member of any number of teams. This is an example of a [many-to-many](http://en.wikipedia.org/wiki/Many-to-many_%28data_model%29) relationship and will require a [join table](http://en.wikipedia.org/wiki/Junction_table). Let's call this table `memberships`:


{% highlight ruby %}
class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.belongs_to :team, null: false
      t.belongs_to :user, null: false
    end
  end
end
{% endhighlight %}



We've intentionally left out the uniqueness constraint in this example to illustrate its pitfalls. Also, don't miss the null constraints! These join records don't make much sense without pointing in both directions.

Let's we have the respective models [set up as needed for such a relationship](http://guides.rubyonrails.org/association_basics.html#the-has-many-through-association). Time to take them for a spin:


{% highlight ruby %}
t = Team.create!    # => #<Team id: 1>
t.users             # => []
u = User.create!    # => #<User id: 1>
t.users << u        # => [#<User id: 1>], nice!
t.users << u        # => [#<User id: 1>, #<User id: 1>], WHOOPS!
Membership.all      # => [#<Membership id: 1, team_id: 1, user_id: 1>, #<Membership id: 2, team_id: 1, user_id: 1>]
{% endhighlight %}



As you can see, without the uniqueness constraint we allow users to be a member of a team _more than once_. That doesn't make much sense (I recently experienced this [first hand](https://github.com/iamvery/snapme-web/issues/13)). Now we'll lock this table down by adding the constraint. In SQL, uniqueness is enfored by creating a "unique" index. This index may span multiple columns to ensure uniqueness with respect to multiple attributes:


{% highlight ruby %}
class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.belongs_to :team, null: false
      t.belongs_to :user, null: false
      t.index [:team_id, :user_id], unique: true
    end
  end
end
{% endhighlight %}



That's pretty much it! Now the database won't allow multiple membership records to exist that reference the same team and user.


{% highlight ruby %}
t = Team.create!  # => #<Team id: 1>
t.users           # => []
u = User.create!  # => #<User id: 1>
t.users << u      # => [#<User id: 1>], nice!
t.users << u      # => [#<User id: 1>], thanks for no errors, Rails!
{% endhighlight %}



_**Note:** You won't be able to adjust the migration as I did in the example without rolling it back first._


### Adding Constraints to Existing Tables


As always, it is tricky to add constraints to existing tables because we are unable to assume the state of the data will allow such constraints to be added. For uniqueness we need to make sure the target column is unique before adding the constraint. Here is an idea to get your wheels turning:


{% highlight ruby %}
# Assume widgets have a `foo` string column with no constraints
class AddUniquenessConstraintToWidgetFoo < ActiveRecord::Migration
  def up
    execute "UPDATE widgets SET foo = coalesce(foo,'') || id"
    add_index :widgets, :foo, unique: true
  end

  def down
    # For simplicity we won't allow the rollback of this migration as it is
    # difficult to get the data in exactly the same state as before the
    # migration.
    raise ActiveRecord::IrreversibleMigration
  end
end
{% endhighlight %}



Since we're assuming there are no constraints on `foo` we first need to make sure it is at least an empty string, so we [coalesce](http://www.postgresql.org/docs/9.2/static/functions-conditional.html#FUNCTIONS-COALESCE-NVL-IFNULL) its value to an empty string. Then we [concatenate](http://www.postgresql.org/docs/9.1/static/functions-string.html) that value with the record's `id` since we know it as a unique value. The resulting value will always be unique to the record!

You may also be interested in [my solution](https://github.com/iamvery/snapme-web/commit/d2ad7aa0091822915265882b511785ef9e5e6196) to the team membership problem mentioned above.



## Until next time…


I hope that you now have an understanding of the uniqueness database constraint and why it can really help improve your app's data integrity. There is one other constraint that was overlooked in the memberships example. That'll be our next target: foreign keys.



* * *





## Other Posts






  * [Coding Rails with Data Integrity, Part 1]({{ site.baseurl }}/blog/coding-rails-with-data-integrity) (null constraints and default values)


  * [Coding Rails with Data Integrity, Part 2]({{ site.baseurl }}/blog/coding-rails-with-data-integrity-part-2) (uniquness constraints)



What other ways have you come up with to ensure data integrity in your apps? We'd love to hear what you think!
