---
author: Jay Hayes
date: 2014-01-15 20:57:52+00:00
layout: post
title: Code Review in Four Steps
wordpress_id: 4504
categories:
- Craftsmanship
- Culture
canonical: http://www.bignerdranch.com/blog/code-review-four-steps
---

Originally posted on the [Big Nerd Ranch Blog](http://www.bignerdranch.com/blog/code-review-four-steps).

---

When I started at Big Nerd Ranch, I was starved for [code review](http://en.wikipedia.org/wiki/Code_review). I had received very few deep, insightful comments on the code I had produced up to that point. Then the code review process at Big Nerd Ranch changed the game for me. 

[![one does not simply do code review]({{ site.baseurl }}/img/blog/2014/01/code-review.jpg)]({{ site.baseurl }}/img/blog/2014/01/code-review.jpg)

I quickly found out how valuable code review is—not just as a programmer, but also as a reviewer. I began learning about new strategies and tools for solving problems, along with new ways to use the tools I already had. And reviewing code myself forced me to think about my preconceptions of code and figure out how to effectively communicate my views to others.

### The Process

The code review process is quite simple, really:

  1. Read all code written by a developer over the last few days.
  2. Understand the changes.
  3. Offer actionable feedback.
  4. Follow up with discussion.

#### Read

You should look at the diff itself as well as the context that it exists in. To do so:

  1. Open up the project and select the target branch.

[![branch]({{ site.baseurl }}/img/blog/2013/12/branch.jpg)]({{ site.baseurl }}/img/blog/2013/12/branch.jpg)

  2. View the commits.

[  
![commits]({{ site.baseurl }}/img/blog/2013/12/commits.jpg)]({{ site.baseurl }}/img/blog/2013/12/commits.jpg)

  3. Starting with the oldest commit you would like to review, read them in chronological order.

As you read through the commits, consider the notes and analyze the diff. You'll begin to build a mental model of [the story being told by the commits]({{ site.baseurl }}/blog/small-distinct-commits-say-you-care/). With experience, you'll be able to quickly decide what is important enough to devote time to, and what may be quickly breezed over (such as whitespace commits).

#### Understand

It's one thing to read code and another thing entirely to understand it. You can start your review by looking for obvious mistakes such as typos, syntax errors, stale comments and the like. You should also consider the readability of the code. If the role of an object is unclear, you may consider commenting on its responsibility or naming. (Naming is a notoriously difficult problem, and code review can be a great way to work fuzzy names into concrete identifiers that clearly communicate the purpose of objects and methods.)

The goal here is to understand another programmer's decisions. This may involve viewing [more context](https://github.com/blog/1705-expanding-context-in-diffs) or asking questions. If you have difficulty grokking a set of changes, that might indicate a flaw in the design.

After gaining understanding, you are ready to comment on the code.

#### Respond

The best question to ask yourself when leaving a comment is: "Is this comment actionable?" While it is encouraging to litter code with "+1" and "Awwww yeah! Dat code is HAWT!", that kind of feedback can grow old.

**Remember**: Every comment you make will notify the programmer whose code you're reviewing, and potentially consume his or her time with reading and following up. 

Your comments should include a call to action:

  * "Have you considered eager-loading these records to reduce the number of queries needed? (i.e. `SomeModel.includes(:related_models)`)"
  * "This object appears to carry too much responsibility. You may consider extracting each responsibility into individual objects to more clearly define the boundaries of logic. What do you think about that?"

Notice that the last example is followed up with a question. This reminds the person you're reviewing that your word is not gospel, but rather a suggestion. The developer may have good reason behind his or her decisions, and should be given the benefit of the doubt.

When reviewing, always ask yourself if a comment you're about to leave is actually valuable. There are many times that I've typed a long comment and subsequently thrown it out because it really didn't offer value. Yes, throwing it out is a waste of your time, but sending it may end up wasting the developer's time as well. 

#### Discuss

If you've provided excellent comments on someone's work, conversation will spring up. Further discussion may be needed in order to find a suitable solution, or the reviewee may simply disagree with you. Be ready to support your opinions, and don't be afraid to admit your own error.

### Go forth and provide value!

Confronting your assumptions about the way code should look and feel forces you to clearly articulate those ideas. You will inevitably grow as a result, and I am amazed by how quickly knowledge spreads in both directions when code review is taken seriously by everyone involved.

Do you practice code review? Does your process differ? Let us know how!
