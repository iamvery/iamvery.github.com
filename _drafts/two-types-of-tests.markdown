---
layout: post
title: There Are 2 Types of Tests
---

Testing is difficult.
Testing is important.

Having worked on many projects and written many tests, I have concluded that there are only two types of tests.
**Unit tests** and **integration tests**.
You may know them by many names, but they fall cleanly into these two categories.
Let me explain...

## Unit Tests

> unit - an individual thing
— Dictionary.app

A unit test attempts to drive the scope of what's being tested down to a tiny, distinct thing.
A unit.
Humans are bad at thinking about lot's of information at once.
Unit tests play to this.
You are only thinking about a single, interesting piece of functionality.
If a unit test feels pointless, it probably is.
Seeing behavior in isolation allows you to iterate on it until the implementation is right.

If you hear nothing else, **unit tests are a powerful tool in driving the design of a system. They discourage coupling.**

### Isolation

Personally, this is big goal during unit testing.
By isolating the object under test, you can omit concern about how collaborating objects behave.
This allows focus on the unit you're working with.

In practice, you may find it difficult to pull off.
Don't beat yourself up.
Instead closely consider each actor in the test and how it affects execution.
Also realize that coupling is a side effect of implementation.
It may very well be true that an alternate design would pave way for easier isolation.
This is why the Single Responsibility Principal is so important.

## Integration

> Everything else.

Literally this.
Every test that is not a unit (read: isolated) test is an integration test.

> integration - combine one thing with another so they become a whole
— Dictionary.app

While unit tests validate the behavior of a small piece _in_ your system, **integration tests validate your system works together.**
Integration tests go by many names: features, acceptance tests, request tests, UI tests, and no doubt many more.
All of these are integration tests.
That is they test how some set of collaborators work together.

## Why is this so hard?

> There are only two hard things in Computer Science: cache invalidation and naming things.
— Phil Karlton

It's been quoted many times.

> name - a word by which a thing is known

A thing is named in order to know what it is.
As such many names have been given to these two types of tests.
In a Ruby on Rails application you may hear tests in `spec/models` referred to as unit tests.
They are unit tests only in as much as they fulfill the definition of a unit test.
The point is often times the type of test is confused with its location in a project.
This is a fallacy.
One that often confuses readers about the purpose a test serves.
Use organization to your advantage.
Organize your test suite to communicate the purpose of tests.
Avoid surprises for future readers (including yourself).
