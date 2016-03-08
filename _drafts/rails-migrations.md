---
layout: post
title: Rails Migrations
---

We had a lively conversation today at [Big Nerd Ranch][bnr] about Rails migrations.
What are they really for?
How long should you keep them around?
What about this crazy schema.rb file?!
TIL WE HAZ OPINIONS!

⚠️ The views of this post are my own.
This is in no away a representation of our team's view of the subject.
Quite the contrary, actually.

## The Migration Files

Migrations are an extremely powerful tool used to apply small transformations to your app's database structure.
This helps you keep all the databases involved in the development of your app in sync:
* your development environment
* your test environment
* your coworker's ⤴️
* staging env(s)
* production

With that, you are able to avoid a lot of the pain of managing database structure across your team and deployment.

### Can I delete them?

It depends (doesn't it always).
Test Double says, ["Keep them working"][td].
This is supported by stating that a team should not be left to "trust the veracity of a generated [schema] file that they can no longer validate."
Let's take a moment to talk about that schema file.

## The Schema File

Your Ruby on Rails project likely has one.
The schema file (either db/schema.rb or db/structure.sql) is a representation of the current structure of your database.
When you dump the schema (e.g. `bin/rake db:schema:dump`) the current structure of your database will be written to the schema file.
This happens every time you run migrations.

Why have this file?

### Load

Let's start by answering: where is this file used?

It's used by the rake task `db:schema:load`, which itself is used by other tasks, `db:setup` for example.
This task is used to initialize a new database with the current structure of the database.
It is assumed that any new database initialized in this way will structurally match all other (prod, dev, test) dbs in the wild.

It's quite common place (the default even) for the schema to be loaded before tests are run.
So running your test suite in this way is a sort of integration test of the schema file.

### Authority

The [Rails guides][rails-guides] refer to the schema file by saying:

> That role [authority] falls to db/schema.rb or an SQL file which Active Record generates by examining the database.

The framework designers intend for this file to be an authoritative representation of the database's structure.
So you must take great care to make sure the generated changes to your schema file match the changes you intended in your migrations.
You're quite likely to see some conflicts between branches that change the database structure.
This is unavoidable, but it is very important that you resolve those conflicts carefully.
Also be warned that not all database structures can be represented in the default Ruby schema.rb file (e.g. triggers).
In such a case, you will need to consider switching to [the SQL structure.sql file][sql-schema].

So why have the file? The Rails answer is because it serves as the definitive definition of the structure of your app's database.

## So can I delete migration files?

Well, at this point it's something of a phylisophical debate steaped in opinion.
If you choose to trust your schema file as an authoritative representation of the database (I do!), the migration files are of no use after they have been run in every environment.
If you chose to go with Test Double's approach and keep them runnable forever, then you will need to get into the habit of running them often.
In that case, I would recommend building the database from your migration files in continuous integration rather than using the schema file as is the default.
If you choose to trust the migration files in this way, is the schema file really anything more than a cache?
How will you know there's a problem with it?

Either way, you're putting your trust into something, and you will want some level of confidence that your trust is not being violated.
Good test practice is your best confidence builder in programming.


[bnr]: https://www.bignerdranch.com/
[sql-schema]: http://edgeguides.rubyonrails.org/active_record_migrations.html#types-of-schema-dumps
[rails-guides]: http://guides.rubyonrails.org/active_record_migrations.html#schema-dumping-and-you
[td]: http://blog.testdouble.com/posts/2014-11-04-healthy-migration-habits.html
