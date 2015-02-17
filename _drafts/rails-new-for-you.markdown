---
layout: post
title: A "rails new" For You
---

Recently, I went on a personal endeavor to determine the best way to create
a new Rails app pre-configured to my liking. I was sick and tired of wasting
time replacing and configuring test runners, adding development gems I prefer,
and reinventing the README. Why did it take so long for me to do this?

## .railsrc

For some reason it took me a long time to discover this handy script. Following
the convention of other ["run configuration" files](wikipedia-config-files),
you can add options here that you wish to be included every time you `rails
new`.

My config...

* skips `bundle install` (handled later)
* skips `.keep` files
* skips [spring](https://github.com/rails/spring)
* skips Test::Unit (I prefer RSpec)
* users PostgreSQL instead of SQlite

Here it is:

<script src="http://gist-it.appspot.com/https://github.com/iamvery/dotfiles/blob/c9e10af36a17d4b21b3dcb4dedfcd08acc7af280/.railsrc"></script>

## Rails App Template

The command line options can only get me so far. To complete my desired
pre-configuration, it's time to automate the things with [Rails application templates](rails-app-templates).

App templates allow you to define a procedure used to config an app. It has
built in hooks for `bundler` and `git`. My config...

* installs preferred gems
* configures test runner
* removes turbolinks
* cleans up Gemfile
* installs bin/bootstrap script
* adds a reasonable README
* commits each change separately

Here is the full template:

<script src="http://gist-it.appspot.com/https://github.com/iamvery/dotfiles/blob/c9e10af36a17d4b21b3dcb4dedfcd08acc7af280/.rails_template.rb"></script>

I keep all my configuration files in [a Gist](config-gist) so they can be
downloaded as needed.

To make sure the template is always used for new apps, I added an alias to
my environment.

<script src="http://gist-it.appspot.com/https://github.com/iamvery/dotfiles/blob/c9e10af36a17d4b21b3dcb4dedfcd08acc7af280/.bash_profile?slice=47"></script>

Creating a new app is as simple as `railsup next_big_thing`.

## Voila!

This turned out to be a great learning experience. The task wasn't as daunting
as I had imagined it to be. I am always working to improve these things, so
keep an eye on [my dotfiles](dotfiles) if you're interested.

[wikipedia-config-files]: http://en.wikipedia.org/wiki/Configuration_file
[rails-app-templates]: http://guides.rubyonrails.org/rails_application_templates.html
[config-gist]: https://gist.github.com/iamvery/6c87c9e191d32603aa78
[dotfiles]: https://github.com/iamvery/dotfiles
