---
layout: post
title: Your First Elixir Plug
---

[Plug][plug] is fundamental to [Phoenix][phoenix] web apps in Elixir.
It's sort of the Elixir equivalent to Ruby's [rack].
Let's make a small plug.

## Project setup

Let's start by creating a new [Mix][mix] project for our code.
If nothing else, this is very helpful for managing dependencies.

```
$ mix new elixir_plug
# ...
$ cd elixir_plug
```

Now add the [Plug][plug] and [cowboy][cowboy] dependencies.

```diff
 # mix.exs
 # ...
 defp deps do
-  []
+  [plug: "~>1.1", cowboy: "~>1.0"]
 end
```

Plug is an Elixir specification for web applications.
Cowboy is an Erlang HTTP server.
An adapter for Cowboy exists in Plug that makes it much more convenient to work with.

Next install these dependencies.

```
$ mix deps.get
```

## Module Plug

Plugs come in two forms, functions and modules.
For this example, you'll create a module plug.
In order for a module to be used as a plug, it must implement `init/1` and `call/2`.
The `init/1` function is used to initialize a plug with some options.
The `call/2` function applies transformations to the connection.

Create a simple plug.

```elixir
# lib/hi_plug.ex
defmodule HiPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hi!")
  end
end
```

Before breaking it down line-by-line, let's see it in action!

```
$ iex -S mix
iex> Plug.Adapters.Cowboy.http(HiPlug, [])
{:ok, #PID<...>}
```

Now open http://localhost:4000 and see your amazing application in action!

<img src="/img/blog/2016/03/plug-browser.png" width="512">

Let's break it down.
First, the name of the module is arbitrary.
Give it an expressive name.
Then you import the `Plug.Conn` module.

```elixir
import Plug.conn
```

This allows you to call functions in that module without having to say `Plug.Conn` every time.
For example, the function `put_resp_content_type` comes from `Plug.Conn` and could be called as `Plug.Conn.put_resp_content_type`.
This short-hand is a convenience.

Next, two functions are defined on our module, `init/1` and `call/2`.
These functions are the required interface for a module to be used as a plug.
The `init/1` function initializes the plug with some options.
In your case, it doesn't change the options, but it may transform them in some way during initialization.

The `call/2` function is called anytime the plug is run.
Your `call/2` takes the connection value and adds a response type and then the response itself.
With that you essentially have a very simple web app implemented as a plug.

## Start the server

To finish things up, let's add one more feature.
When the project is run, automatically start the web server.
To do this, we'll take advantage of the [application callback][app-callback].
This is just a module with a `start/2` function called when the application starts.
It's effectively a hook into your code.

Create a new module for you web server.

```elixir
# lib/web_server.ex
defmodule WebServer do
  def start(_type, _args) do
    Plug.Adapters.Cowboy.http(HiPlug, [])
  end
end
```

In this case, we don't do anything with the arguments to `start/2` so we prefix them with an underscore to indicate they won't be used.
Then we kick off the server using the cowboy adapter just as we did earlier in `iex`.

Finally, add the application callback to your `mix.exs` file.
It's as a `mod:` key in the `application` keyword list.

```diff
 # mix.exs
 # ...

 def application
-  [applications: [:logger]]
+  [mod: {WebServer, []}, applications: [:logger]]
 end
```

The empty list is passed along as the second argument to `start/2` in your module (`_args` in our case).

That's it, your app starts when ever you kick off `iex -S mix`.
With that running, you can view you app at http://localhost:4000.


[phoenix]: http://www.phoenixframework.org/
[mix]: http://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html
[plug]: https://github.com/elixir-lang/plug
[cowboy]: https://github.com/ninenines/cowboy
[app-callback]: http://elixir-lang.org/getting-started/mix-otp/supervisor-and-application.html#the-application-callback
[rack]: http://rack.github.io/
