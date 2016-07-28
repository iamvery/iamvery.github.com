---
layout: post
title: "Testing External Dependencies with Fakes"
description: Third-party solutions complicate automated testing in your app. Solve this by using fakes to test external dependencies in your code.
excerpt: Third-party solutions can solve difficult problems when you're writing code, but relying on remote services makes writing automated tests more complicated. You can use fakes to solve this problem.
tags:
- testing
- ruby
- big nerd ranch
- web
canonical: https://www.bignerdranch.com/blog/testing-external-dependencies-with-fakes/
---

Communication with remote services is often an inevitable part of writing interesting software. Difficult problems (e.g., address validation) are easily solved by integrating with third-party solutions.

Unfortunately, relying on remote services complicates the goal of writing automated tests for your application. Without decoupling your code from these external factors, your test suite grows continually slower each time an example communicates with the outside. Additionally, services may or may not be available during the run, causing test failures unrelated to your code.

An effective strategy to address this problem is to draw a line at the boundary between your code and the service. At that boundary, replace the external integration with a stand-in, a fake.

## A Testing Strategy

To get familiar with this approach, consider an example. Say you want to add a feature to your application that fetches page titles using the [Open Graph protocol][og]. After some research, you settle on a small library that gets the job done.

```
OpenGraph.new("https://bignerdranch.com").title
# time passes as request is made and response is processed...
# => "Big Nerd Ranch - App Development, Training, & Programming Guides"
```

### Wrap It

[Justin Searls][searls] recently wrote an article that clarifies a phrase you often see: ["Don't mock what you don't own"][ownership]. As he points out, the purpose of that phrase is to encourage test writers to wrap external dependencies in an application-owned adapter.

The benefit is two-part:

- It establishes a consistent interface for accessing the behavior you need.
- It serves "as a specification of what you're using in that dependency."

Go ahead and introduce a trivial adapter for your Open Graph integration.

```
class WebPage
  def initialize(url)
    @open_graph = OpenGraph.new(url)
  end

  def title
    open_graph.title
  end

  private

  attr_reader :open_graph
end
```

This step may seem unnecessary, but there is value in establishing a consistent interface in your application. The benefit is quickly felt if you later decide to use a different Open Graph library, or the initialization of the library you're using is awkward. With your adapter's interface established, you're ready to create a test fake.

Note: It is important to write tests that verify your adapter correctly integrates with the library it wraps. However, those tests feel very off-subject for this post. I've written a pull request to demonstrate how one might [test the adapter][commits].

### Fake It

To avoid the pitfalls of external influence on your tests, implement a fake that is a [duck type][duck] for `WebPage`. The fake should be simple, but as [Martin Fowler says][fowler], it must have a _working implementation_ to support dependent code.

Consider this implementation that returns a URL's hostname as its title:

```
require "uri"

class FakeWebPage
  attr_reader :url

  def initialize(url)
    @url = url
  end

  def title
    host
  end

  private

  def host
    uri.host
  end

  def uri
    URI(url)
  end
end
```

This stand-in provides an alternative strategy for determining the page title without having to make a web request. Try it out for yourself, and see that it's good enough.

```
FakeWebPage.new("http://some_web_page.com")
# => "some_web_page.com"
```

It seems to get the job done. Now you can configure your application to use the test fake when running tests.

Here's a pull request that shows a similar [implementation in the context of an app][commits].

## Confidence in the Implementation

No real integration happens in test. How can you be sure it really works? That's a genuine concern.

The library code (the bit performing external communication) must itself have integration tests written that verify its own external behavior. When using a third-party library, this is often a responsibility that maintainers take seriously. If you have written the integration (or you don't trust theirs), test the integration directly in isolation. You might use a tool like [VCR][vcr] to record and play back web requests for tests.

For critical integrations, you may even want to allow external communication by an isolated portion of your tests that is only run in certain environments. This provides the absolute confidence that the real integration works. However, realize that it comes at the cost of speed and reliability (e.g. external service may go down).

## Responsibility

Fundamentally, the struggle of how to test external integrations is one of responsibility. Is it really your application code that should bear the task of maintaining this integration? No. That burden falls to library code. It might be that the library is born out of your application's codebase (see Rails' [`./lib` directory][lib]). But the library itself is not concerned with the domain of your application, e.g. selling widgets. Conversely, the application should not be concerned with the domain of the library, e.g. fetching and parsing Open Graph metadata. These distinctions become easier to see when library code is extracted as a dependency from your application.

**You might say that an application should be built solely out of domain-specific code, libraries and configuration.**

## Summary

- Create thin wrappers to establish consistent, app-owned interfaces for faking.
- Replace these adapters with fakes to avoid external dependencies in your tests.
- Enjoy speedy tests that are unaffected by remote services you do not control.

[vcr]: https://github.com/vcr/vcr
[og]: http://ogp.me/
[duck]: https://en.wikipedia.org/wiki/Duck_typing
[commits]: https://github.com/iamvery/pinster-cable/pull/6
[lib]: http://blog.codeclimate.com/blog/2012/02/07/what-code-goes-in-the-lib-directory/
[fowler]: http://martinfowler.com/bliki/TestDouble.html
[searls]: https://twitter.com/searls
[ownership]: https://github.com/testdouble/contributing-tests/wiki/Don't-mock-what-you-don't-own
