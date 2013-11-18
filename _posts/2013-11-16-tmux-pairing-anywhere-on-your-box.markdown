---
layout: post
title: "Tmux Pairing Anywhere: On Your Box"
---

**TL;DR** Armed with my [`pair`](http://goo.gl/BrqApT) and
[`ng`](http://goo.gl/vlgsrz) scripts in one hand and [ngrok](https://ngrok.com)
in the other, I have finally found a quick, effective and secure way to pair
program with anyone, anywhere using tmux on my local box.

If you want more information about the setup, read on.

---

\*\***Updated**\*\* November 17, 2013

[Tmux](http://tmux.sourceforge.net) is a fantastic productivity tool for
developers that prefer to stick with the command line. The hardest part is
sharing a session from _**anywhere**_ (securely).

I'd like to share my setup for remote tmux pair programming with you.  Here's
what we're going to accomplish:

1. [Allow remote, key based auth to your machine](#step_one_authentication_without_a_password)
2. [Connect from _anywhere_](#step_two_connect_from_anywhere)
3. [Bonus Round: More about my scripts](#bonus_round_my_trickery)

## Step one: Authentication without a password

Seriously, you don't want to hand out passwords. [PKI](http://en.wikipedia.org/wiki/Public-key_infrastructure)
is a great way to allow connections by handshake with users. True story: if
you're a Github user, your public keys are [publically available](https://api.github.com/users/iamvery/keys).
Don't worry, they're supposed to be public, and this allows us to do very cool
things.

[Chris Hunt's](http://chrishunt.co/) [github-auth](https://github.com/chrishunt/github-auth)
gem allows you to manage Github users' public keys in your
`~/.ssh/authorized_keys` file so that you can easily allow/revoke users'
ability to remote into your machine.

Install github-auth:

    $ gem install github-auth

We use the gem's binary `gh-auth` to authorize Github users to remote into our
machine. It's pretty straightforward:

    $ gh-auth add --users iamvery --command="$(which tmux) attach -s pairing"

This adds the public keys for the specified Github user "iamvery" (me!) to the
your `~/.ssh/authorized_keys` file. The `--command` option allows us to specify
a [forced command](http://oreilly.com/catalog/sshtdg/chapter/ch08.html)
(you'll have to browse down for section on "Forced Commands") which
automatically connects them to the tmux session.

You can remove added users by the similar `gh-auth remove` command. Luckily
all of this is wrapped up for simplicity by my [`pair script`](#pair_script).

## Step two: Connect from _anywhere_

This is the _**holy grail**_ of a solid tmux pairing setup. It's not very
practical to pair with someone logged into your account locally. In most cases
your pair is far removed from you, and networking is hard. You might be at a
coffee shop or tethering to your 3G smartphone on the way to Disney World. In
these situations it's tricky to provide an SSH connection back to your machine
without access to a firewall's port forwarding settings (if even you would want
to do such a thing).

### Enter ngrok

The beautiful people at [ngrok.com](https://ngrok.com) have created an excellent
tool for establishing reverse tunnels back to your machine. This is great for
sharing a local development web server over the Internet. However, with their
inclusion of TCP in the list of supported protocols, they hit it out of the
park. The implication is that we can establish a reverse _TCP_ connection back
to our computer through their service. Yes.

[Signup](https://ngrok.com/signup), [download](https://ngrok.com/download) and
install `ngrok` (I like to keep it in my `~/bin` directory). Then spin up a TCP
tunnel for SSH:

    $ ngrok --proto=tcp 22  # tunneling to SSH
    ngrok                                              (Ctrl+C to quit)

    Tunnel Status                 online
    Version                       1.6/1.5
    Forwarding                    tcp://ngrok.com:12345 -> 127.0.0.1:22
    Web Interface                 127.0.0.1:4040
    # Conn                        0
    Avg Conn Time                 0.00ms

This command takes over the terminal with some connection information, so you
may want to open up another terminal window to test it out. You'll notice the
connection to your machine is available at `ngrok.com` on port `12345`. Let's
connect to our machine through ngrok and make sure the setup is working:

    $ ssh -p 12345 tmux@ngrok.com
    Password:  # unless you're use key-based auth... You are using key-based auth, right?
    tmux$          # :boom:

Any connection error when running this SSH command indicates a problem with
your ngrok setup or perhaps a typo in the SSH command.

I encourge you to [support this service](https://ngrok.com/pay). They probably
just made your day.

### tmate.io

I was just turned on to this service. [http://tmate.io](http://tmate.io) is an
interesting take on terminal pairing.  It's a fork of tmux proper that does the
heavy lifting of setting up and securing the connection between you and your
pair. Check it out, it may be just what you need, but do take the time to
[understand the tradeoffs](https://github.com/nviennot/tmate/issues/21).

## Bonus Round: My trickery

I keep a lot of my environment [on Github](https://github.com/iamvery/dotfiles).
I have been working on a couple scripts to make this process easier.  They're
not perfect, but hopefully they're helpful. I'll to continue to improve them
over time.

<h3 id="pair_script"><code>~/bin/pair</code></h3>

My [`pair` script](http://goo.gl/BrqApT).  makes the processes of adding and
removing tmux users a little easier. It also automates the process of spinning
up your pairing environment.

When all the dependencies are met, it's as easy as this:

    $ pair up iamvery  # where "iamvery" is the github username of your pair

This will:

1. Open a new tmux session named "pairing"
2. Start the ngrok reverse tunnel in the top tmux pane
3. Echo the SSH command your pair will need to connect with in the bottom pane
4. Copy this command to your clipboard (using [`reattach-to-user-namespace`](https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard))

Try `pair --help` for the full command signature.

<h3 id="ng_script"><code>~/bin/ng</code></h3>

My [`ng` script](http://goo.gl/vlgsrz) is a small wrapper of the ngrok command.
It also figures out the SSH command needed to connect to your tunnel. Since
ngrok doesn't provide a simple means for determining the port it selected for
your connection we have to do a little scraping of the local ngrok web server
to gather all the pieces.

The end result is a couple of helpful commands:

    $ ng connect
    #  connects and runs the ngrok tunnel
    $ ng ssh
    ssh -p 12345 your_username@ngrok.com

This script is used by the `pair` script to put all the pieces together for a
quick remote pairing session.

## Closing

Wow, this was a _long winded_ post, but hopefully full of great information.
Pair programming with tmux is a fantastic in a lot of ways, but doing it remotely
has always been a little tricky. It feels great to _finally_ have a setup that's
quick and easy to spin up when the mood strikes.

What do you think of the method? Is it horribly insecure? Do you love it? Hate
it? Let me know!
