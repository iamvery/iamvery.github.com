---
author: Jay Hayes
date: 2013-09-25 20:22:16+00:00
layout: post
title: Small, Distinct Commits Say You Care
wordpress_id: 3867
categories:
- Craftsmanship
canonical: http://www.bignerdranch.com/blog/small-distinct-commits-say-you-care
---

Originally posted on the [Big Nerd Ranch Blog](http://www.bignerdranch.com/blog/small-distinct-commits-say-you-care).

---

As programmers, we revel in the details. We'll pour our time and money into growing our craft for the sheer joy of it. That's why we're incredible. We discover the pricelessness of [version control](http://en.wikipedia.org/wiki/Revision_control) systems and [services](https://github.com) early in our careers. Tools like Git give us the feeling of invincibility!

These tools are much more than a safety net. They are _communication devices_. They communicate the story of a project, the programmers involved, the purpose for decisions made and even the programmer's [disposition](http://whatthecommit.com). In this post I want to review some ways we can improve our use of version control and why this really does matter. I prefer Git, so my examples will be given as such.


### The Future You is Tired (and lazy)


Have you ever looked at a piece of code and said to yourself "What were they thinking when they wrote this?!" I certainly have. Unfortunately "they" is usually _me_. Thanks to git we can _get_ to the bottom of it.

For this post, I created an [example repository](https://github.com/iamvery/commits-blog). The example follows the development of the critically important class [`Mug`](https://github.com/iamvery/commits-blog/blob/a59e52e64faa15bb6ac5877cffe0b491920737d0/mug.rb). Over time we've added a number of [features to `Mug`](https://github.com/iamvery/commits-blog/blob/nice-history/mug.rb), including the ability to drink from it by `sips` and `gulps`. If you attempt to take a drink from an empty mug, an error is raised. Why would we want to go as far as raising an error for this condition? Let's find out!


#### The Right Way


In an [ideal world](https://github.com/iamvery/commits-blog/tree/nice-history), commits are small and focused. [Under pressure](https://github.com/iamvery/commits-blog/tree/ugly-diff), we might take some shortcuts. Let's first look at the good case:

~~~
master ? » git checkout nice-history
Switched to branch 'nice-history'
nice-history ? » git blame mug.rb | grep raise
8d0f066a (Jay Hayes 2013-09-17 10:27:56 -0500 33) raise "You're all out of #{content}" if empty?
~~~

The blame points us to the commit [8d0f066a](https://github.com/iamvery/commits-blog/commit/8d0f066a8798758a23b302f3f425f7d7e943891a).

![A example, concise commit]({{ site.baseurl }}/img/blog/2013/09/a-clean-commit.jpg)

Aha, we want to be unable to drink from an empty mug because we don't think air is worth drinking. Additionally, the commit message reveals that it is associated with an [issue](https://github.com/features/projects/issues), [story](https://www.pivotaltracker.com/help/gettingstarted) or some other additional information specific to the project which is numbered `1337`. Following that back to your tracking system may reveal even more information about the feature.

Yay, that's quite helpful!


#### The Wrong Way


What if the commits weren't so nicely tailored? The blame might have landed you with something like [0826c3f3](https://github.com/iamvery/commits-blog/commit/0826c3f3f993163ef64d169c3f2f5a7e60c4d82f).

![An example, overloaded commit]({{ site.baseurl }}/img/blog/2013/09/a-messy-commit.jpg)

It's notably more difficult to figure this one out. First, the diff is large, so it's unclear what all has changed. Luckily, the commit message attempts to cover the changes, but unfortunately it does fall short as the error condition goes completely unmentioned. If your commits look like this while you're actively working on a feature, all is not lost! Below we'll jump in our time machine and make history do our bidding.


### No Fear of Commitment


Does commitment scare you? Don't sweat it. Git provides the ability to warp history into the story you want to tell. We have [git-rebase](https://www.kernel.org/pub/software/scm/git/docs/git-rebase.html), which [isn't just about changing the base of a branch](http://git-scm.com/book/en/Git-Tools-Rewriting-History), as its name suggests. I use it in combination with [git-add --patch](https://www.kernel.org/pub/software/scm/git/docs/git-add.html) on a daily basis to manipulate my commits into a meaningful story before pushing them to a remote (and sometimes even after, if I'm working in a feature branch). I inevitably find myself wanting to remove, squash, split or reword experimental commits that are unclear or unneeded for the feature.

**Pro-tip**: If you use Github, the [compare view](https://github.com/blog/612-introducing-github-compare-view) is a really handy way to review the your commits. [tig](https://github.com/jonas/tig) is also a handy command line git interface that can enable you to quickly walk the commit history.

I rebased the above mentioned [mammoth commit](https://github.com/iamvery/commits-blog/commit/0826c3f3f993163ef64d169c3f2f5a7e60c4d82f) into something that is [more manageable](https://github.com/iamvery/commits-blog/compare/be67688...tidy-up). Here's a screencast of the process:

https://vimeo.com/74891693

**Warning**: You probably don't want to rewrite the history of a "shared" branch. Doing this can cause issues for other users of the branch. Typically, you will only want to rewrite history on local or [feature](http://martinfowler.com/bliki/FeatureBranch.html) branches that you own.


#### Summary


There are a number of benefits from commiting code in small, distinct changesets:



	
  * Easy to read

	
  * Easy to understand

	
  * Easy to reference - and subsequently [git-revert](https://www.kernel.org/pub/software/scm/git/docs/git-revert.html) if neccessary


Taking the time to carefully tailor your commits is a great way to make the life of others and the future you happier. Have you discovered additional benefits to keeping commits clear and concise?
