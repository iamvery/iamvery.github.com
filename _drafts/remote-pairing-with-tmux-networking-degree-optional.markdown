---
layout: post
title: "Remote Pairing with Tmux: Networking Degree Optional"
---

**TL;DR** Armed with my [`pair`](https://github.com/iamvery/dotfiles/blob/master/bin/pair)
and [`ng`](https://github.com/iamvery/dotfiles/blob/master/bin/ng) scripts in
one hand and [ngrok](https://ngrok.com) in the other, I have finally found a
quick, effective and secure way to pair program with anyone, anywhere using
tmux on my local box.

If you want more information about the setup, read on.

---

[Tmux](http://tmux.sourceforge.net) is a fantastic productivity tool for
developers that prefer to stick with the command line. The hardest part is
sharing a session from _**anywhere**_ (securely).

I'd like to share my setup for remote tmux pair programming with you. It's
going to be a bit involved, so hang on tight. Here's what we're going to
accomplish:

1. [Confingure a local tmux user & group](#step_one_configure_a_tmux_user__group)
2. [Create a directory for tmux session socket files](#step_two_create_the_tmux_session_directory)
3. [Allow remote connections without a password](#step_three_authentication_without_a_password)
4. [Connect from _anywhere_ (hint: ngrok)](#step_four_connect_from_anywhere)
5. [Bonus Round: More about my scripts](#bonus_round_my_trickery)

## Step one: Configure a tmux user & group

> Warning: These instructions are for Mac OS X! You Linux users got this ;)

Mac OS X provides a nice GUI for creating users and groups (warning: using a
GUI during the setup of a text-only development environment may include irony).
You can find more information about [the process here](http://www.macworld.com/article/2029539/configuring-mountain-lions-users-and-groups.html).
I would recommend you create `tmux` as a "non-admin" user. Additionally, you'll
need to make sure your personal user is a part of the `tmux` group.  See this
screenshot, it's pretty simple:

![Mac OS X Account Preferences](/images/mac-os-x-accounts-preferences.jpg)

### Enable Remote Login (SSH)

This configuration confused me when upgrading to Mavericks recently, so I
thought it worth mentioning. Mac OS X requires you to specify which users and
groups are allowed to login remotely (i.e. ssh). It's a simple change in
`System Preferences > Sharing` to enable this for the `tmux` group. Here's my
setup:

![Mac OS X Remote Login Preferences](/images/mac-os-x-remote-login-preferences.jpg)

## Step two: Create the tmux session directory

Tmux sessions may be shared via [Unix sockets](http://en.wikipedia.org/wiki/Unix_domain_socket)
by using the `tmux -S` option. This will allow distinct users of a system to attach
to the same tmux session as long as they have permission to access the socket.

Create the directory for your tmux sockets and set its permissions:

    $ sudo mkdir /var/tmux
    $ sudo chown tmux:tmux /var/tmux  # The tmux user and group own it
    $ sudo chmod 2770 /var/tmux       # Give user and group full access + setgid bit

The [setgid](http://en.wikipedia.org/wiki/Setuid#setgid_on_directories) bit
makes sure that files and directories created in this directory inherit the
group ID of this directory. So any sockets created are inherently owned by
`tmux`.

## Step three: Authentication without a password

Seriously, you don't want to hand out passwords. [PKI](http://en.wikipedia.org/wiki/Public-key_infrastructure)
is a great way to allow connections by handshake with users. True story: if
you're a Github user, your public keys are [publically available](https://api.github.com/users/iamvery/keys).
Don't worry, they're supposed to be public, and this allows us to do very cool
things.

### Create the `~/.ssh/authorized_keys` file for `tmux`

This directory and file must exist to allow PKI authentication. The creation is
straightforward. We'll do it on the `tmux` user's behalf from our account:

    $ sudo su tmux -c "mkdir -m 0700 ~/.ssh"
    $ sudo su tmux -c "touch ~/.ssh/authorized_keys"
    $ sudo su tmux -c "chmod 0644 ~/.ssh/authorized_keys"

The permissions of this directory and file [are important](http://stackoverflow.com/a/6377073).

### github-auth

[Chris Hunt's](http://chrishunt.co/) [github-auth](https://github.com/chrishunt/github-auth)
gem allows you to manage Github users' public keys in your
`~/.ssh/authorized_keys` file so that you can easily allow/revoke users'
ability to remote into your machine.

Install github-auth:

    $ gem install github-auth

Now, since our pair will be connecting to the `tmux` user, we need to use this
utility to add our pair's keys to the `tmux` user's `authorized_keys`. To do
this from our own account, we use `sudo`:

    $ tmux_command="$(which tmux) -S /var/tmux/pairing attach"
    $ sudo su tmux -c "GEM_HOME=$GEM_HOME gh-auth add --users iamvery --command=\"$tmux_command\""

Basically this executes the `gh-auth` command on behalf of the `tmux` user,
adding the public keys for the specified Github user "iamvery" (me!) to the
`tmux` user's `~/.ssh/authorized_keys` file. The `GEM_HOME` part is important
because we need the command to know where to find the `gh-auth` gem binary
which is installed in our environment. Finally, we specify that this user will
automatically connect to the shared tmux session by using the `--command`
option.

You can remove added users by the similar `gh-auth remove` command. Luckily
all of this is wrapped up for simplicity by my [`pair script`](#pair_script).

## Step four: Connect from _anywhere_

This is the _**holy grail**_ of a solid tmux pairing setup. Sure it's great that
any "tmux" user on your system can attach to a shared session, but how often
will you be pairing with someone _on your network_?  In most cases your pair is
far removed from you,and networking is hard. You might be at a coffee shop or
tethering to your 3G smartphone on the way to Disney World.  This makes it
tough to provide an SSH connection back to your machine without access to a
firewall's port forwarding settings (if even you would want to do such a
thing).

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

## Bonus Round: My trickery

I keep a lot of my environment [on Github](https://github.com/iamvery/dotfiles).
I have been working on a couple scripts to make this process a little easier.
They're not perfect, but hopefully they're helpful. I'll to continue to improve
them over time.

<h3 id="pair_script"><code>~/bin/pair</code></h3>

My [`pair` script](https://github.com/iamvery/dotfiles/blob/master/bin/pair).
makes the processes of adding and removing tmux users a little easier. It also
automates the process of spinning up your pairing environment.

When all the dependencies are met, it's as easy as this:

    $ pair up iamvery  # where "iamvery" is the github username of your pair

This will:

1. Make sure iamvery's Github public keys are installed for the `tmux` user
2. Open a new tmux session at `/var/tmux/pairing`
3. Start the ngrok reverse tunnel in the top tmux pane
4. Echo the SSH command your pair will need to connect with in the bottom pane
5. Copy this command to your clipboard (using [`reattach-to-user-namespace`](https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard))

Try `pair --help` for the full command signature.

<h3 id="ng_script"><code>~/bin/ng</code></h3>

My [`ng` script](https://github.com/iamvery/dotfiles/blob/master/bin/ng) is a
small wrapper of the ngrok command. It also figures out the SSH command needed
to connect to your tunnel. Since ngrok doesn't provide a simple means for
determining the port it selected for your connection we have to do a little
scraping of the local ngrok web server to gather all the pieces.

The end result is a couple of helpful commands:

    $ ng connect
    #  connects and runs the ngrok tunnel
    $ ng ssh
    ssh -p 12345 tmux@ngrok.com

This script is used by the `pair` script to put all the pieces together for a
quick remote pairing session.

## Closing

Wow, this was a _long winded_ post, but hopefully full of great information.
Pair programming with tmux is a fantastic in a lot of ways, but doing it remotely
has always been a little tricky. It feels great to _finally_ have a setup that's
quick and easy to spin up when the mood strikes.

What do you think of the method? Is it horribly insecure? Do you love it? Hate
it? Let me know!
