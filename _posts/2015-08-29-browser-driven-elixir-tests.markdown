---
layout: post
title: Browser-driven Elixir Tests
description: Automated testing of features in Elixir with a headless browser
---

An indispensable tool of web development is the ability to drive a browser for automated feature testing.
In Ruby, we tend to reach for [Capybara][capybara] (a test framework) and [Poltergeist][poltergeist] (a [PhantomJS][phantomjs] driver).
Regardless of what tool you choose, browser-driven feature tests are a great way to ensure the expected behavior of your apps.
Let's do that in Elixir.

**TL;DR** Check out this [example of how one might configure Hound][hound-example] to run browser-driven feature tests in Elixir.

## Hound

On such tool in the Elixir ecosystem, is [Hound][hound].
Must like Capybara, Hound is a test framework which provides an interface for using a webdriver to test the behavior of pages.
Also like Capybara, it does not make any assumption about the driver you wish to use.
Instead you must configure it to use the driver of your choice, such as [Selenium][selenium], [ChromeDriver][chromedriver], or [PhantomJS][phantomjs].
Since we're familiar with PhantomJS (and love the headless nature of it), we'll go with that!

## Configuration

The truth is [Akash Manohar][akash] has already written an excellent [blog post about configuring Hound][configuring-hound] to work with [Phoenix][phoenix], so I won't rehash that here.
**Go read this blog!**
Instead, I will mention hit the highlights and emphasize the particulars that tripped me up.

### Webdriver

First, if you haven't already, you will need to install PhantomJS.
If you're on a Mac, this is probably easiest done with [Homebrew][brew].
From the command line:

{% highlight sh %}
$ brew install phantomjs
{% endhighlight %}

The successful completion of that command should add a `phantomjs` command to your path.

{% highlight sh %}
$ which phantomjs
/usr/local/bin/phantomjs
{% endhighlight %}

### 🚨 START THE WEBDRIVER 🚨

Finally, in order to actually run the tests **YOU MUST START THE WEBDRIVER**.
A lot of time was wasted trying to figure this out.
In Ruby with Poltergeist, this step is not necessary as that gem manages the `phantomjs` process for you.

The easiest way to start PhantomJS is:

{% highlight sh %}
$ phantomjs --wd
PhantomJS is launching GhostDriver...
[INFO  - 2015-08-29T16:15:05.347Z] GhostDriver - Main - running on port 8910
{% endhighlight %}

This starts PhantomJS as a webdriver (without the `--wd` option, it starts in interactive mode).
As you can see the driver runs on it's default port `8910` which is conveniently configured by default in Hound.

## Automate The Things

Basically, it isn't great having to remember to start PhantomJS before running your tests.
With a small Bash script, we can make sure it's running every time we run our tests.

<script src="https://gist.github.com/iamvery/a50a77a301217c810e42.js"></script>

This will start PhantomJS before running `mix test`.
The `trap` ensures that PhantomJS is stopped when the script exits (or is terminated).
You might drop this in your `./bin/` directory and then a full test run is as easy as `bin/test`.

## Cleaning Up

You may have noticed `--include feature` above.
Using the [technique from my previous post][elixir-pending] you can configure ExUnit to exclude tests tagged with `:feature` by default.
That way tests depending on the webdrive don't fail when you run `mix test` alone.
This option will then ensure that feature tests are included when you run `bin/test`.

I put together an [example application][hound-example] implementing all these ideas.
Check it out: [https://github.com/iamvery/hound-example][hound-example].

One other thing I want to note is that perhaps Hound (or some other small library) could/should manage the `phantomjs` process itself.
I haven't given this a try yet, but it sounds like a good challenge!


[capybara]: https://github.com/jnicklas/capybara
[poltergeist]: https://github.com/teampoltergeist/poltergeist
[phantomjs]: http://phantomjs.org/
[hound]: https://github.com/HashNuke/hound
[selenium]: http://www.seleniumhq.org/projects/webdriver/
[chromedriver]: https://code.google.com/p/selenium/wiki/ChromeDriver
[akash]: http://hashnuke.com/
[configuring-hound]: http://hashnuke.com/2015/06/07/hound-phoenix-framework-integration-testing.html
[phoenix]: http://www.phoenixframework.org/
[mix]: http://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html
[hex]: https://hex.pm/
[brew]: http://brew.sh/
[elixir-pending]: http://iamvery.com/2015/07/25/elixir-pending-tests.html
[hound-example]: https://github.com/iamvery/hound-example
