---
author: Jay Hayes
date: 2013-04-09 16:23:45+00:00
layout: post
title: Ancient City Ruby 2013
wordpress_id: 2447
categories:
- Conferences
- Ruby on Rails
---

Originally posted on the [Big Nerd Ranch Blog](http://www.bignerdranch.com/blog/ancient-city-ruby).

---

St. Augustine, Florida, was packed with brilliant minds this past week, and I'm glad to have been a part of it. It's a bit startling to think about all the information that was delivered and receiving during the two short days we met for [Ancient City Ruby](http://ancientcityruby.com) (ACR).





If you're a Ruby developer you probably won't be surprised that the talks fell pretty cleanly into three camps: your environment, testing and pairing.





## Summary





Here's a glimpse of what blew my mind:







  * [Russ Olsen](http://blog.russolsen.com) gave us some great tips on cutting down the noise in our apps so that we can get down to the important stuff: programming.


  * [Nell Shamrell](http://www.nellshamrell.com) delivered a wonderful love story about test driven development in narrative form.


  * [Chris Hunt](http://chrishunt.co) filled his time with a ton of ridiculously insightful [`vim` and `tmux` usage](https://speakerdeck.com/chrishunt/ruby-productivity-with-vim-and-tmux).


  * [Jim Weirich](http://onestepback.org) gave us the rundown of his [`rspec-given`](http://rubygems.org/gems/rspec-given), and how it can make our tests lean and mean.


  * [Eric Redmond](http://about.me/coderoshi) taught all we'd ever need to know about distributed programming and communication.


  * [Jacob Burkhart](https://twitter.com/beanstalksurf) gave us the [rundown on background jobs](http://jacobo.github.io/background_jobs).


  * [Paolo Perrotta](http://ducktypo.blogspot.com) told us things we'd never known about our (chicken) brains!


  * [Andy Lindeman](http://alindeman.github.io) represented us like a champ with some _sick_ live [coding of a mock library](http://goo.gl/9hvLg) for `MiniTest`.


  * [Ben Orenstein](https://twitter.com/r00k) showed us how to refactor like a TDD champ… and did it live.


  * [Sandi Metz](http://sandimetz.com) boiled the massive subject of unit testing down into [a brilliantly minimal set of rules (pic)](http://i.imgur.com/7Y61dWv.jpg) that will make any programmer better.


  * [Avdi Grimm](http://avdi.org) [reminded us](https://speakerdeck.com/avdi/pairing-is-caring) that pairing makes you and me better programmers. Do it well and do it often!


  * [Ben Smith](https://github.com/benjaminleesmith) humbled us with his [insight into Ruby gem security](https://speakerdeck.com/benjaminleesmith/hacking-with-gems-ancient-city-ruby) and scared the crap out of some of us!





## Development Environment





What's arguably the most important part of our (virtual) development environment? The text editor, of course! If you came to ACR with any doubt of the current trend in our community, it should be settled. It's a vim, vim world.





One of the coolest things I picked up for vim is use of its macros. [Chris Hunt](http://chrishunt.co) showed us how to create a macro _capable of doing math_ to calculate people's ages and sort lines accordingly. Check out [his presentation](https://speakerdeck.com/chrishunt/ruby-productivity-with-vim-and-tmux) if you're interested in the details.





Another tool we can't seem to get enough of is [`tmux`](http://tmux.sourceforge.net). Just about everyone had something to say about this slick little terminal multiplexer. I was also introduced to [`wemux`](https://github.com/zolrath/wemux), a wrapper that is supposed to smooth out some of the issues you have when trying to share a tmux session with others. Additionally, I was reminded of [`mosh`](http://mosh.mit.edu), a "mobile shell" written by MIT that aims to let you work effectively in a remote shell over a highly latent network. Sweet.





## Testing





If there's anything we claim to be in the Ruby community, it's testers. We can't have a conversation about our craft without getting into testing, and this is a wonderful quality. The trick has always been doing it right, and that's not an easy problem to solve.





Our very own [Andy Lindeman](http://alindeman.github.io) stepped up to the plate ready to crush his opportunity as a first-time conference speaker. [He delivered](https://docs.google.com/presentation/d/1laaQYHFyzcTJzlB9qMmEHyoHIB-S93p9B4L8SbbhoTw/edit#slide=id.p) what was described as some of the absolute best live coding I've ever experienced. It was hard to believe he was actually typing, it was that smooth.





Jim Weirich told us about his [`rspec-given`](http://rubygems.org/gems/rspec-given) library, which adds some elegant syntax to rspec for writting minimal specs. He asserts (ha) that the descriptive string following `it` is duplication that should be easily read in the spec itself and showed us how `rspec-given` addresses that problem.





[Sandi Metz](http://sandimetz.com) attacked unit testing and broke it down into some [simple rules](http://i.imgur.com/7Y61dWv.jpg). We should worry about testing methods, and those can be categorized into two camps:







  1. Query


  2. Command





After learning that, here's how to spec them:




{% highlight ruby %}
| Message      | Query         | Command                            |
| ------------ | ------------- | ---------------------------------- |
| Incoming     | Assert Result | Assert direct, public side effects |
| Sent to self | Ignore                                             |
| Outgoing     | Ignore        | Expect to send                     |
{% endhighlight %}





So simple, so elegant, so Sandi.





## Pairing





The last theme was pair programming. All of us do it. All of us like it. [Avdi Grimm](http://avdi.org) used his extensive experience to [tell us](https://speakerdeck.com/avdi/pairing-is-caring) why it's essential. Pair programming is arguably one of the most effective ways to help a new developer level up to a seasoned status in as little time as possible. It requires great energy, but delivers big results.





Avdi reminded us to "put out the pairing welcome mat" with [www.pairprogramwith.me](http://www.pairprogramwith.me/) and his pairing badge. He also mentioned the use of [#pairwithme](https://twitter.com/search?q=%23pairwithme&src=typd) and [#pairingwith](https://twitter.com/search?q=%23pairingwith&src=typd) Twitter hash tags to get the word out.





## Honorable Mention: Security





[Ben Smith](https://github.com/benjaminleesmith) brought some [serious perspective](https://speakerdeck.com/benjaminleesmith/hacking-with-gems-ancient-city-ruby) to the table with his talk on gem security. He reminded us that despite the general trust and character in the Ruby community, **_gems are code executing on your computer_**. That means they shouldn't be trusted implicitly.





He proved his point by showing us several inconspicuous gems that seemed to perform run-of-the-mill tasks with a little "extra." He went on to demonstrate gems capable of inserting themselves into systems as log readers, source code revealers and private key stealers.





He wrapped up the show by humbling several of us (myself included) by revealing his social experiment `gem install ancient-city-ruby` (don't do it!). Long story short, the victims had their usernames [emblazoned](https://speakerdeck.com/benjaminleesmith/hacking-with-gems-ancient-city-ruby?slide=118) across the projection screen mid-talk (and now the Internet). Burn.





### Summary





This is a one-track, regional conference to keep your eye on. The folks in attendence seemed to have a blast—I know I did. You definitely don't want to miss out on this one next year!



