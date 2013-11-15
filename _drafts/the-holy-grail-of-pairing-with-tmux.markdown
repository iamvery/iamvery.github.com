---
layout: post
title: The Holy Grail of Pairing with Tmux
---

[Tmux](http://tmux.sourceforge.net) is a fantastic productivity tool for
developers that prefer to stick with the command line. The hardest part is
sharing a session from _**anywhere**_ (with security in mind).

There are [loads of tools and suggestions](http://www.pairprogramwith.me), but
so far I haven't found a great solution that let's you share a connection to
your computer without having to deal with the setup and maintenance of a box
in the cloud (at least to some degree). For me the sun has set on that day. Read
on.

## Step one: Configure a tmux user & group

> Warning: These instructions are for Mac OS X!

The Mac OS gives us nice GUIs for creating users and groups (Warning: using a
GUI during this process may include irony). You can find more information about
[the process here](http://www.macworld.com/article/2029539/configuring-mountain-lions-users-and-groups.html).
I would recommand you make `tmux` a (non-admin) user. Additionally, you'll want
to make sure your user is a part of the `tmux` group.  See this screenshot,
it's pretty simple:

![Mac OS X Account Preferences](/images/mac-os-x-accounts-preferences.jpg)

### Enable Remote Login (SSH)

This configuration bit me when upgrading to Mavericks recently, so I thought it
bore mentioning. Mac OS X requires your specific which users and groups are
allowed to login remotely (i.e. ssh). It's trivial to allow the `tmux` group to
login remotely. Here's my setup:

![Mac OS X Remote Login Preferences](/images/mac-os-x-remote-login-preferences.jpg)

### Automatically attach to session

When someone logs into the tmux user, they really have any need to do anything
in the account other than attach to the tmux session, so let's update they're
profile to automatically connect:

    $ ssh tmux@localhost 'echo "tmux attach /var/tmux/pairing" >> .bash_profile'

Now they'll automatically attempt to connect to a shared tmux connection at the
socket file `/var/tmux/pairing`.

## Step two: Create the tmux session directory

Tmux sessions may be shared via [Unix sockets](http://en.wikipedia.org/wiki/Unix_domain_socket).
This will allow multiples users of a system to attach to the same tmux session
as long as they have permission to access the socket.

Create the directory for your tmux sockets and set its permissions:

    # you may need to sudo these!
    $ mkdir /var/tmux
    $ chown tmux:tmux /var/tmux
    $ chown 2770 /var/tmux

The [setgid](http://en.wikipedia.org/wiki/Setuid#setgid_on_directories) bit
makes sure that files and directories created in this directory inherit the
group ID of this directory!

## Step three: Authentication without a password

Seriously, you don't want to hand out passwords. [PKI](http://en.wikipedia.org/wiki/Public-key_infrastructure)
is a great way to allow connections by handshake with users. True story: if
you're a Github user, your public keys are [publically available](https://api.github.com/users/iamvery/keys).
Don't worry, they're public, and this allows us to do very cool things. Chris
Hunt's [github-auth](https://github.com/chrishunt/github-auth) Rubygem allows
you to manage Github users' public keys in your `~/.ssh/authorized_keys` file.

Install github-auth:

    $ gem install github-auth

Now, since our pair will be connecting to the `tmux` user, we need to use this
utility to add our pairs keys to the `tmux` user's `authorized_keys`. Answer: `sudo`.

    $ sudo su tmux -c "GEM_HOME=$GEM_HOME gh-auth add --users iamvery"

Basically this executes the `gh-auth` command on behalf of the `tmux` user. The
`GEM_HOME` part is important here because we want it to have access to the
`gh-auth` command in your environment. You can substitude the `add` part of the
command with `remote` to remove a user's keys.

## Connect from _anywhere_

This is the _**holy grail**_ of a solid tmux pairing setup. Sure it's great that
any "tmux" user on your system can attach to a shared session, but how often
will you be pairing with someone on your network that is remoted into your
machine?  In most cases your pair is far removed from you,and networking is
hard. You might be at a coffee shop, or even tethering to your 3G smartphone.
This makes it tough to provide an SSH connection back to your machine without
access to a firewall's port forwarding settings.

### Enter ngrok

The beautiful people at [ngrok.com](https://ngrok.com) have provided an excellent
tool for establishing reverse tunnels back to your machine. This is great for
sharing a local development web server over the Internet. However, with their
inclusion of TCP in the list of supported protocols, they hit it out of the
park. The implication is that we can establish a reverse _tcp_ connection back
to our computer through their service. Yes.

Download and install `ngrok` (I like to keep it in my `~/bin` directory). Then
spin up a tcp tunnel:

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
connection to your machine is available at `ngrok.com:12345`. Let's connect to
our machine and make sure the setup is working:

    $ ssh -p 12345 your_local_username@ngrok.com
    Password: # unless you're use key-based auth... You are using key-based auth, right?
    $ # :boom:

Any connection error when running this SSH command indicates a problem with
your ngrok setup or perhaps a typo.

I encourge you to support this service. They just made your day.

## My trickery

I keep a lot of my environment [on Github](https://github.com/iamvery/dotfiles).
I have been working on a couple scripts to make this process a little easier.
They're not perfect, but hopefully they're getting better.

First is my [`pair` script](https://github.com/iamvery/dotfiles/blob/master/bin/pair).
This baby makes the processes of adding and removing tmux users a little easier
as well as getting the tunnel spun up and helping you out with the ssh command.

The second is my [`ng` script](https://github.com/iamvery/dotfiles/blob/master/bin/ng).
This one just wraps up the ngrok command and builds the ssh command displayed in
the former script. Ngrok doesn't give us a great way to determine the port it
selects for the tunnel, so this some some scrapting of the local ngrok web
server.

## Closing

Wow, this was a _long winded_ post, but hopefully full of great information.
Pair programming with tmux is a fantastic in a ton of ways, but doing it remotely
has always been a little tricky. Finally putting the pieces together feels
awesome!

What do you think of the method? Is it horribly insecure? Do you love it? Let me
know! :)
