---
layout: post
title: Effective Testing with RSpec 3
description: A book review. TL;DR 👍
tags:
- ruby
- testing
---

If you know me, you know I have opinions about testing software. I've been writing software for over ten years now. The single most important skill that I have picked up is writing automated tests. It helps make our work more predictable and increases confidence to make changes. Heck, it's even fun! If you haven't used tests to drive a feature, check out [my workshop from RailsConf][rc-ws].

Cool, so I love testing. So you can imagine my excitement when [Myron Marston][myron] asked me to have a look at his new book, [Effective Testing with RSpec 3][rspec-book]. At 600+ (iPad) pages, this is a book _packed_ with information. In a way it has multiple personalities, but they'll all help you write better software.

## The Philosopher

Part one of the book is about establishing _why_ you should write tests and use RSpec. It answers great philosophical questions like:

- Why are my tests so slow?
- Are these tests worth their weight?
- How can I make progress without failure distracting me?

The book goes into just the right amount of detail to address these things and more. You're left feeling empowered to get started. I can say as someone that is relatively well-experience with RSpec that I still learned a lot. In a lot of ways, it was like I was reading pages out of my own experience. My kneck is sore from nodding. The writing style and progression just enhances your experience as a reader. Read it. You'll learn. 💪

## The Teacher

Part two is an extended, guided tutorial. I must say this was one of the most surprising and exciting parts of the book. For a long time, I've maintained that we do a really bad job teaching software testing as it usually doesn't extend beyond `expect(1+1).to eq(2)`. With this part of the book, you get a real-world example of building feature with tests. Actually not all that different from my [workshop][rc-ws].

Now let me say, experienced testers may not agree with the details of this part of the book. I certainly found myself yelling at paper (erm, iPad glass) at times. But you know what? Software engineers will never agree on the precise details of programming computer's brains. So set those opinions aside and appreciate the fact that Myron and Ian went to great lengths to provide a real example for folks getting started. Thank you! The community appreciates it. And it sets the stage for interesting conversations about tradeoffs and decision making. 👏

## The Librarian

Part three through the end, the Librarian. This is a big, friggin' reference. RSpec is shamelessly chocked full of features. All in the name of expressive, self-documenting specs.

> With great numbers of features, comes great need for reference. 
> — Uncle Sam, probably

RSpec has been pretty stable for awhile, so I imagine this reference will remain valuable for years. If you take the time to read the latter parts of this book, you. will. learn. something. It doesn't matter who you are or how much experience you have. I'm pretty sure Myron and Ian learned of RSpec features by writing it. Don't miss the matcher cheat sheet at the end! 🙌

## The End

In summary, this is certainly a recommended book for Ruby programmers. Read with an open mind, the first half of the book is useful for _all_ programmers. Testing is such an important part of a software developer's practice. Do it. Read this book. Read other books. Write tests. ❤️



[rc-ws]: https://github.com/iamvery/testing-workshop/releases/tag/v1
[myron]: https://twitter.com/myronmarston
[rspec-book]: https://pragprog.com/book/rspec3/effective-testing-with-rspec-3
