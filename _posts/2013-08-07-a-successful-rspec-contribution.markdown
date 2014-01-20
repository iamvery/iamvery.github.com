---
layout: post
title: A Successful RSpec Contribution
---

Ever since I started using [turnip](https://github.com/jnicklas/turnip), I've
been a pretty big fan of the
[gherkin](https://github.com/cucumber/cucumber/wiki/Gherkin) syntax for my
acceptance specs. Recently, upon upgrading to RSpec 2.14, I ran into [an issue](https://github.com/jnicklas/turnip/issues/79#issuecomment-20836212)
with turnip. Having wanted to level up in open source contributions for awhile,
I quickly tried to troubleshoot the issue so that I could offer a pull request.

I was able to narrow the problem down to RSpec which prevented the `*.feature`
files from loading. Being unfamiliar as I am with the RSpec codebase, I wasn't
able to come up with a solution on my own, but I did write up a
[detailed bug report](https://github.com/rspec/rspec-core/issues/993) for the
minds behind RSpec to take a crack at.

OSS to the rescue! It was awesome to see it picked up, fixed, and closed out in
less than 24 hours. This is not only a testament to the great work that the
RSpec core team does (specifically [Jon Rowe](https://github.com/JonRowe) in
this case), but also the power of open source as a whole. Here's hoping my next
contribution comes patch included!
