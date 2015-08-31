---
layout: post
title: ⚠️ Phoenix Database Config ⚠️
description: This problem has stumped me several times. So be warned!
---

I've created two Phoenix apps.
With both of them, I was momentarily stumped by a weird error message.
Be warned!

## The Problem

After creating a new Phoenix app, when we try to do something, e.g. `mix ecto.create` we see an error like this.

{% highlight sh %}
● features ~/Code/OSS/investment_time » mix test
11:54:28.385 [error] GenServer #PID<0.301.0> terminating
** (exit) %Postgrex.Error{message: "tcp connect: nxdomain", postgres: nil}
11:54:28.392 [error] GenServer InvestmentTime.Repo.Pool terminating
** (exit) %Postgrex.Error{message: "tcp connect: nxdomain", postgres: nil}
** (ArgumentError) argument error
    :erlang.send(InvestmentTime.Repo.Pool, {:"$gen_cast", {:checkin, #Reference<0.0.6.1725>}})
    (elixir) lib/gen_server.ex:424: GenServer.do_send/2
    (ecto) lib/ecto/pool.ex:158: Ecto.Pool.do_run/4
    (ecto) lib/ecto/adapters/sql.ex:231: Ecto.Adapters.SQL.query/6
    (ecto) lib/ecto/adapters/sql.ex:209: Ecto.Adapters.SQL.query/5
    (ecto) lib/ecto/adapters/sql.ex:170: Ecto.Adapters.SQL.query!/5
    (elixir) lib/enum.ex:1261: Enum."-reduce/3-lists^foldl/2-0-"/3
    (ecto) lib/ecto/adapters/postgres.ex:55: Ecto.Adapters.Postgres.execute_ddl/3
    (ecto) lib/ecto/migrator.ex:36: Ecto.Migrator.migrated_versions/1
    (ecto) lib/ecto/migrator.ex:134: Ecto.Migrator.run/4
    (ecto) lib/mix/tasks/ecto.migrate.ex:61: Mix.Tasks.Ecto.Migrate.run/2
    test/test_helper.exs:5: (file)
    (elixir) lib/code.ex:307: Code.require_file/2
    (elixir) lib/enum.ex:537: Enum."-each/2-lists^foreach/1-0-"/2
    (elixir) lib/enum.ex:537: Enum.each/2
    (mix) lib/mix/tasks/test.ex:178: Mix.Tasks.Test.run/1
    (mix) lib/mix/cli.ex:55: Mix.CLI.run_task/2
{% endhighlight %}

If you look very closely, there is a pretty good hint at the problem: `%Postgrex.Error{message: "tcp connect: nxdomain", postgres: nil}`.
There appears to be some problem connecting to the database.

## The Solution

I found a single [Github comment][comment] which solved my problem.

> I had the same nxdomain problem.
> It turned out that my issue was the the env var PGHOST=/tmp, which is the first url that postgrex is using to connect to the db.
> I got around this by setting hostname: "localhost" in my config.exs.

So there we have it.
We must specify a `hostname: "localhost"` option for our database configuration.
This tells Ecto to connect at "localhost" rather than trying to follow `$PGHOST`.
I suspect this has something to do with [my environment][my-pghost].
I connect to Postgres.app via Unix sockets stored at this location.
Here's [a post][pg-unix-sockets] with a little more information about that config.

Finally, here's an [example commit][commit] in an app I made fixing the problem.

{% highlight diff %}
 config :hello_phoenix, HelloPhoenix.Repo,
   adapter: Ecto.Adapters.Postgres,
-  username: "postgres",
-  password: "postgres",
+  hostname: "localhost",
   database: "hello_phoenix_dev",
   pool_size: 10
{% endhighlight %}


[comment]: https://github.com/ericmj/postgrex/issues/21#issuecomment-120958847
[my-pghost]: https://github.com/iamvery/dotfiles/blob/ff0330044db09f9b3df32a6fb63d98beaa8ce8be/.environment#L3
[pg-unix-sockets]: http://iamvery.com/2013/06/17/postgresapp-with-unix-socket.html
[commit]: https://github.com/iamvery/investment-time/commit/1f733e70631d661e71100de33f4472c6d60b12ea
