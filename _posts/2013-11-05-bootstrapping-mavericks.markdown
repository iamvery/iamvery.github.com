---
layout: post
title: Bootstrapping OS X 1.9 (Mavericks) for Development
---

**Warning**: The value of this post may be questionable at best. It is being
birthed out of a place of deep frustration after hours of trying to get my
development environment back up and running for my work post-upgrade.

Upgrading my system to Mavericks went off largely without a hitch. I did share
in the [Gmail issues](http://www.tuaw.com/2013/10/23/how-mavericks-ruined-apple-mail-for-gmail-users/),
but in the end the effect on my work was relatively benign. The biggest problem
I ran into was unfortunately bootstrapping my environment for development on my
current primary project.

The main problem-causing dependency has been: [capybara-webkit](https://github.com/thoughtbot/capybara-webkit).
More specifically, its dependency on [QT](http://qt-project.org). There have been
a [number of problems](https://www.google.com/search?q=mavericks+qt&oq=mavericks+qt&aqs=chrome..69i57j69i61.3522j0j1&sourceid=chrome&espv=210&es_sm=119&ie=UTF-8)
reported around the web about QT on Mavericks. In my case, I tend to use [Homebrew](http://brew.sh)
to manage such dependencies. Unfortunately, its [broken](https://github.com/mxcl/homebrew/issues/21608).

Honestly, I'm not completely sure what all the issues have been, but here's what
I did to get my environment back up to snuff. In all likelihood some of this is
unecessary, but I thought it worth documenting:

* Completely uninstalled Homebrew and all its installed libs
* Completely removed all rubies and gems
* Installed QT manually from the [.pkg installer](http://download.qt-project.org/official_releases/qt/4.8/4.8.5/qt-mac-opensource-4.8.5.dmg)
* Reinstalled Homebrew
* Reinstalled rubies (I like [ruby-install](https://github.com/postmodern/ruby-install)
  and [chruby](https://github.com/postmodern/chruby) these days)
* `bundle install`ed my project
* _Finally_ green specs!

Any QT installed by Homebrew, even when the [installation was successful](https://github.com/mxcl/homebrew/pull/23793)
was causing `Errno::EPIPE` errors after a few specs ran. That seems to be due to
the ["webkit_server binary crash(ing)"](https://github.com/thoughtbot/capybara-webkit/issues/68#issuecomment-2133695).

Hopefully all you fine folks out there have been met with _much_ better success
than myself upgrading to Apple's shiny new OS! Let me know if you have any questions.
Maybe I can help you avoid some stress ;)
