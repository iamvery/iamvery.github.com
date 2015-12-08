---
layout: post
title: There Are 2 Types of Tests
excerpt:
  Features, requests, acceptance, etc.
  They're either isolated or integration.
---

Testing is difficult.
Testing is important.

Having worked on many projects and written many tests, I have concluded that there are only two types of tests.
Isolated tests and integration tests.
You may know them by many names, but they fall cleanly into these two categories.
Let me explain...

## Isolated Tests

> _isolate_ - remain alone or apart from others
> — Dictionary.app

An isolated test drives the scope of what's being tested down to a tiny, distinct thing.
A unit.
You may know these as unit tests, but it seems [folks don't agree][martin-unit-tests] on whether unit tests should be isolated.

Humans are bad at thinking about lot's of information at once.
Isolated tests play to this.
You are only thinking about a single, interesting piece of functionality.
By doing this, you can avoid concern about how collaborating objects behave and affect your test.
Seeing behavior in isolation allows you to iterate on it until the implementation is right.
If a particular unit test feels useless, it probably is.

If you hear nothing else, **isolated tests are a powerful tool in driving the design of a system.
They discourage coupling.**

> _coupling_ - the pairing of two items
> — Dictionary.app

In practice, you may find it difficult to pull off.
Don't beat yourself up.
Instead closely consider each actor in the test and how it affects execution.
Also realize that coupling is often a side effect of implementation.
Go watch some [Sandi Metz talks][sandi-talks] and understand that an alternate design might pave way for easier isolation.
This is why the Single Responsibility Principal is so important.

## Integration Tests

> Literally everything else.
> — Jay Hayes

Every test that is not isolated is an integration test.

> _integration_ - combine one thing with another so they become a whole
> — Dictionary.app

While isolated tests validate the behavior of a single piece _in_ your system, **integration tests validate your system works as a whole** (or some part of the whole).
Integration tests go by many names: features, acceptance tests, request tests, UI tests, and no doubt many more.
All of these are integration tests.
That is they test how some set of collaborators work together.

## Why is this so hard?

> There are only two hard things in Computer Science: cache invalidation and naming things.
> — Phil Karlton

It's been quoted many times.

> _name_ - a word by which a thing is known
> — Dictionary.app

A thing is named in order to know what it is.
As such many names have been given to these two types of tests.

The point is often times the type of test is confused with its location in a project.
This is a fallacy.
One that often confuses readers about the purpose a test serves.
Use organization to your advantage.

**Organize your test suite to communicate the purpose of tests.
Avoid surprises for future readers** (including yourself).


[martin-unit-tests]: http://martinfowler.com/bliki/UnitTest.html
[sandi-talks]: http://www.sandimetz.com/speaking/
