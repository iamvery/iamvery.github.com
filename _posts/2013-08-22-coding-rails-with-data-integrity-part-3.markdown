---
author: Jay Hayes
date: 2013-08-22 17:57:10+00:00
layout: post
title: Coding Rails with Data Integrity, Part 3
wordpress_id: 3620
categories:
- Ruby on Rails
canonical: http://www.bignerdranch.com/blog/coding-rails-with-data-integrity-part-3
---

Originally posted on the [Big Nerd Ranch Blog](http://www.bignerdranch.com/blog/coding-rails-with-data-integrity-part-3).

---

In our [previous posts](http://bit.ly/1d5PKiS) about data integrity in Rails, we covered  null constraints, default values and uniqueness constraints. These database constraints help ensure that data exists where it's supposed to and in a form that makes sense for your [domain model](http://en.wikipedia.org/wiki/Domain_model).

This time, I would like to take a look at [referential integrity](http://en.wikipedia.org/wiki/Referential_integrity). We'll find out how the database can be harnessed to ensure related records may trust one another under certain circumstances.


## Gotta Support the Team


**Disclaimer**: Rails' default database is SQLite, which doesn't support foreign key constraints out of the box. In order to attempt the concepts in this post, try another SQL database such as [PostgreSQL](http://www.postgresql.com) or [MySQL](http://www.mysql.com).

In [Coding Rails with Data Integrity, Part 2]({{ site.baseurl }}/blog/coding-rails-with-data-integrity-part-2) I outlined a simple data model where **Users** may be members of **Teams**. This is done by way of the **Membership** join model. Constraints ensure that duplicate and incomplete memberships cannot exist in the database. The migration for memberships looks like this:

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


Unfortunately, this migration fails to guarantee referential integrity. That is records may become orphaned:

{% highlight ruby %}
user = User.create!  # => #<User id: 1>
user.teams.create!   # => #<Team id: 1>
Membership.all       # => [#<Membership id: 1, team_id: 1, user_id: 1>]
user.destroy
Membership.all       # => [#<Membership id: 1, team_id: 1, user_id: 1>]
{% endhighlight %}


Now there is an invalid membership in the database. We have data that relates a team to a user that no longer exists. Following that reference leads to nothing. This fills the database with useless records and may lead to 404 landmines when someone browses memberships.


### The Rails Solution


The keen reader is probably thinking "You can do this stuff with Rails' associations using the `:dependent` option." Yes you can, and it may very well make sense for your app. You may do something like this:

{% highlight ruby %}
class User < ActiveRecord::Base
  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships
end

user = User.create!  # => #<User id: 1>
user.teams.create!   # => #<Team id: 1>
Membership.all       # => [#<Membership id: 1, team_id: 1, user_id: 1>]
user.destroy
Membership.all       # => []
# Thanks, Rails! You did it!
{% endhighlight %}


Something that should be considered is that Rails has a couple of different ways to remove records from the database. A record may either be [`delete`d](http://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-delete) or [`destroy`ed](http://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-destroy). Deletion skips [callbacks](http://api.rubyonrails.org/classes/ActiveRecord/Callbacks.html), and since the `:dependent` option on Rails associations is implemented using callbacks, you could still orphan records by "deleting" them rather than "destroying" them.

{% highlight ruby %}
user = User.create!  # => #<User id: 1>
user.teams.create!   # => #<Team id: 1>
Membership.all       # => [#<Membership id: 1, team_id: 1, user_id: 1>]
user.delete
Membership.all       # => [#<Membership id: 1, team_id: 1, user_id: 1>]
# Shazbot!
{% endhighlight %}


Foreign key constraints enforce referential integrity at the database level. This means referential integrity exists in spite of the application code. The _win_ becomes obvious once you stop thinking of the database as this private slave of the Rails app and instead as an application-independent data-store. One could theoretically introduce another app that interacts with the same database without worry for the integrity of the data.


### Enter Foreigner


Ruby on Rails omits foreign key constraints as a built-in feature, because databases have uneven support for them. The [foreigner](https://github.com/matthuhiggins/foreigner) rubygem is a great library for adding foreign key constraints in your migrations. Below we'll see foreigner in action.

So what _do_ we want to happen to the **Membership** when a referenced **User** is deleted? In this case, it probably makes sense to just delete the membership, since it doesn't mean anything without a user. We'll add a to the member's user reference:

{% highlight ruby %}
class AddUserForeignKeyToMemberships < ActiveRecord::Migration
  def change
    add_foreign_key :memberships, :users, dependent: :delete
  end
end
{% endhighlight %}


The `:dependent` option tells the database to delete this record whenever the referenced record is deleted.

{% highlight ruby %}
user = User.create!  # => #<User id: 1>
user.teams.create!   # => #<Team id: 1>
Membership.all       # => [#<Membership id: 1, team_id: 1, user_id: 1>]
user.delete          # not "destroy" with all those fancy callbacks!
Membership.all       # => []
# Nice! The membership record was automatically deleted
{% endhighlight %}


How about the other side of the relationship? That is, what should happen when a referenced **Team** is deleted? That decision is probably left up to the domain of your app, but for example's sake, let's say we don't want to allow a **Team** to be deleted if it has any users. Constrain it!

{% highlight ruby %}
class AddTeamForeignKeyToMemberships < ActiveRecord::Migration
  def change
    add_foreign_key :memberships, :teams, dependent: :restrict
  end
end
{% endhighlight %}


Now the database will prevent us from deleting a team that has members.

{% highlight ruby %}
team = Team.create!  # => #<Team id: 1>
team.users.create!   # => #<User id: 1>
Membership.all       # => [#<Membership id: 1, team_id: 1, user_id: 1>]
team.destroy         # => ActiveRecord::InvalidForeignKey raised!
# Aww, thanks database :)
{% endhighlight %}


If your app has foreign key constraints, declare them, and let the database do the dirty work!

I want to mention that there are other great libraries out there that allow adding constraints to your database. [Rein](https://github.com/nullobject/rein) is another good example that I haven't used personally. In the end, always use the right tool for the job.



* * *





## Other Posts





	
  * [Coding Rails with Data Integrity, Part 1]({{ site.baseurl }}/blog/coding-rails-with-data-integrity) (null constraints and default values)

	
  * [Coding Rails with Data Integrity, Part 2]({{ site.baseurl }}/blog/coding-rails-with-data-integrity-part-2) (uniqueness constraints)


What other ways have you come up with to ensure data integrity in your apps? We'd love to hear what you think!
