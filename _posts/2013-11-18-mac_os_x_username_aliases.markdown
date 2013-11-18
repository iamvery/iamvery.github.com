---
layout: post
title: Mac OS X User Aliases
---

While working on [tmux pairing configuration](http://iamvery.com/2013/11/16/tmux-pairing-anywhere-on-your-box.html),
I came upon this feature I hadn't seen yet in Mac OS X, user aliases. Basically
you can define a set of alternate login names for your account. This was
particularly interesting to me for keeping my account name _slightly_
anonymous for tmux pairing\*.

You can add an alias for accounts by going to `System Preferences > Accounts`
and accessing the "Advanced Options..." context menu item by right-clicking
your account. I opted to add a `tmux` alias for my account so that pairs may
use this to remote to my machine.

![Mac OS X Accounts](/images/mac-os-x-accounts.jpg)
![Mac OS X Advanced Account Options](/images/mac-os-x-advanced-account-options.jpg)

\* I say "slightly" because while having someone remotely connected to your
shell, there is a pretty good chance they'll get a view of your account name.
If this is a big concern of yours, you may want to consider doing your pairing
in a virtual machine or somewhere in the cloud.
