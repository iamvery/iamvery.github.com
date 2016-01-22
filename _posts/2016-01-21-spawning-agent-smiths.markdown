---
layout: post
title: Spawning Agent Smiths
description:
  State in a functional programming environment is much different than object oriented.
  Implementing something like Elixir's Agent module on your own isn't as hard as you might thing.
---

If you've come to functional programming from an object oriented background, you may have found it hard to grok state in a functional system.
You're accustomed to creating and manipulating objects, but in functional languages everything is **_immutable_**.
Often the answer to this problem is to use processes to store state.
Elixir has an [`Agent`][elixir-agent] which is a simple construct for storing state in processes.
Let's see if we can roll our own `AgentSmith`.

## Remember Agents

When you are first introduced to agents, they appear somewhat magical.
You'll think "If everything is immutable, how are agents mutated?"
The key is: processes are mutable.
This extends beyond the bounds of Elixir.
Processes consume memory, and this memory can grow as they allocate space for variables and such.
By exploiting this quality of processes, they can be used to track changing state in an otherwise immutable sea of values.

Let's remember how agents work in Elixir.

{% highlight elixir %}
iex> {:ok, agent} = Agent.start_link(fn -> [] end)
{:ok, #PID<0.42.0>}
iex> Agent.get(agent, fn list -> list end)
[]
iex> Agent.update(agent, fn list -> ["lol"|list] end)
:ok
iex> Agent.get(agent, fn list -> list end)
["lol"]
{% endhighlight %}

A link is started to an agent, and the agent itself is just a process (see, it's a `PID`).
Then using `update` and `get` you may provide a function used to interact with the value stored in the agent.
Keep in mind there is no constraint on the type of data that may be stored in an agent.
You control the how it's changed and retrieved.

## Agent Smith

With this basic understanding of agents in Elixir, you're ready to implement it yourself.
It shall be known as `AgentSmith`, and it's not as scary as it sounds.

![](/img/blog/2016/01/agent-smith.jpg)

The first thing you need is an `AgentSmith.start_link/1` function.
You know that an agent is just a process, so `spawn` should come to mind.
In particular `spawn_link` as it's nice for errors to propagate to the parent process.

{% highlight elixir %}
defmodule AgentSmith do
  def start_link(func) do
    value = func.()
    spawn_link(AgentSmith, :loop, [value])
  end

  def loop(value) do
    # ???
  end
end
{% endhighlight %}

Focus on the `spawn_link` call for a moment.
This creates a new process executing `AgentSmith.loop/1` and passing in the argument list `[value]`.
While a process is created at this point, it doesn't do anything.
It exits as soon as `loop` returns.

### Messages

In order to interact with this process, it must receive messages.

{% highlight diff %}
defmodule AgentSmith do
  def start_link(func) do
    # ...
  end

  def loop(value) do
+   receive do
      # ???
+   end
  end
end
{% endhighlight %}

Now the agent smith process will wait for a message to be sent to it.
It's time to implement the `get` message.

### Get Message

{% highlight diff %}
defmodule AgentSmith do
  def start_link(func) do
    # ...
  end

  def loop(value) do
    receive do
+     {:get, func} ->
        # ???
    end
  end

+ def get(agent, func) do
+   send(agent, {:get, func})
+ end
end
{% endhighlight %}

A process may now send a message to your agent to "get" something with the given function.
As you can see the `value` is available as an argument to `Agent.loop/1`.
Unfortunately that in another process, so the only way to get that value back to the caller is to send it back in another message.
(Hmm, sending messages. That sounds familiar to some OO programmers... conceptually, yes, but this is friggin' parallelism!)
In order to send a message _back_, you have to know who called...

{% highlight diff %}
defmodule AgentSmith do
  def start_link(func) do
    # ...
  end

  def loop(value) do
    receive do
-     {:get, func} ->
+     {:get, caller, func} ->
        # ???
    end
  end

  def get(agent, func) do
-   send(agent, {:get, func})
+   send(agent, {:get, self, func})
  end
end
{% endhighlight %}

Perfect! Now to send back the value...

{% highlight diff %}
defmodule AgentSmith do
  def start_link(func) do
    # ...
  end

  def loop(value) do
    receive do
      {:get, caller, func} ->
+       send(caller, {func.(value)})
    end
  end

  def get(agent, func) do
    send(agent, {:get, self, func})
+   receive do
+     {value} -> value
+   end
  end
end
{% endhighlight %}

Now the "get" message responds by sending a message back with the value to the caller.
The caller receives the value and it's implicitly returned.

### Keep It Going

One thing's missing here.
After a "get" message is received, the agent process exits.
This is because there is no implicit looping in a `receive` block.
Keeping the agent going is as simple as recursing on the loop with the agent's value.

{% highlight diff %}
defmodule AgentSmith do
  def start_link(func) do
    # ...
  end

  def loop(value) do
    receive do
      {:get, caller, func} ->
        send(caller, {func.(value)})
+       loop(value)
    end
  end

  def get(agent, func) do
    # ...
  end
end
{% endhighlight %}


### Update Message

Getting the value from an agent is fine and all, but state isn't being manipulated.
Let's implement the "update" message.

{% highlight diff %}
defmodule AgentSmith do
  def start_link(func) do
    # ...
  end

  def loop(value) do
    receive do
      # ...
+     {:update, func} ->
+       loop(func.(value))
    end
  end

  def get(agent, func) do
    # ...
  end

+ def update(agent, func) do
+   send(agent, {:update, func})
+ end
end
{% endhighlight %}

The `AgentSmith.update/2` implementation is surprisingly simple.
The magic is in the recursion.
Since the `func` argument takes care of performing the update, it's sent to the agent and used to update the value passed to the next recursion.
Now the next "get" request will be processed by a call to `AgentSmith.loop/1` with the updated value.

![](http://img.pandawhale.com/post-28553-Steve-Jobs-mind-blown-gif-HD-T-pVbd.gif)

That's it?
YES! The state is represented as a series of translations applied to the original value passed to the agent.
Let's try it out.

{% highlight elixir %}
iex> agent = AgentSmith.start_link(fn -> [] end)
#PID<0.42.0>
iex> AgentSmith.get(agent, fn list -> list end)
[]
iex> AgentSmith.update(agent, fn list -> ["lol"|list] end)
{:update, ...}
iex> AgentSmith.get(agent, fn list -> list end)
["lol"]
{% endhighlight %}

The interface isn't exactly like Elixir's `Agent`, but it gets the point across.
For good measure, here's the full implementation.

{% highlight elixir %}
defmodule AgentSmith do
  def start_link(func) do
    value = func.()
    spawn_link(AgentSmith, :loop, [value])
  end

  def loop(value) do
    receive do
      {:get, caller, func} ->
        send(caller, {func.(value)})
        loop(value)
      {:update, func} ->
        loop(func.(value))
    end
  end

  def get(agent, func) do
    send(agent, {:get, self, func})
    receive do
      {value} -> value
    end
  end

  def update(agent, func) do
    send(agent, {:update, func})
  end
end
{% endhighlight %}

This is certainly overly simplified in comparison to Elixir's `Agent` (which uses `GenServer`), but fundamentally it's a great illustration of how to pull off state in a functional system using processes.
What do you think??


[elixir-agent]: https://github.com/dojo-toulouse/elixir-koans/blob/master/utils/Koans.ex#L33-L40
