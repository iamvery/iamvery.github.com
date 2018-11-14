---
layout: post
title: "Feature Tours"
description: TODO
tags:
- testing
- ruby
- web
---

You write tests that serve many different purposes. On one end of the spectrum, there are "unit tests" which isolate small units of behavior in your code to drive out a well-factored design. At the other extreme there are "feature" or "acceptance" tests that allow you to automate the use of a system as a user of it. These tests are great for specifying the system behavior of a _feature_. However, you sometimes still choose to isolate each use case of a feature in its own example. That's where _feature **tours**_ come in.

A _feature tour_ is an acceptance test that "tours" an entire feature in a single example. First question: Why? There are probably many reasons one could conjure up, but here are a few to consider.

## As a user...

Tests at this level are supposed to exercise the system _as a user of it_. Therefore, any direct database access or other "code level" effects of these tests are technically cheating, because a user cannot do them. You sometimes fall to this temptation so that you can "set up the world" in order to run an example. However, it's true that in production the only way for the system to get into the states that you're producing manually is by its use. In this way, your tests are more realistic and less prone to errors in the margins of the behavior being tested.

## Coupling

Another problem with writing code to set up acceptance-level examples is that everything you're writing is in some way coupled to the underlying implementation. Therefore, you will often see this features begin to fail when seemingly unimportant implementation changes are made to the system. This might be categorized as what TestDouble calls a ["NOOOPE" test](https://github.com/testdouble/contributing-tests/wiki/Testing-Pyramid).

## Feature Tours

The proposal is that we write such tests as _tours_ of the feature being exercised. For example, if you're building some basic CRUD functionality in a web app, the test script might look like this:

```ruby
RSpec.describe 'Post management' do
  it 'supports creating, viewing, editing, and deleting' do
    visit '/'

    click_on 'Add Post'
    fill_in 'Title', with: 'An Post'
    fill_in 'Body', with: 'An post body.'
    click_on 'Create Post'

    expect(page).to have_content('Post created.')
    expect(page).to have_content('An Post')
    expect(page).to have_content('An post body.')

    visit '/'
    click_on 'An Post'

    click_on 'Edit'
    fill_in 'Body', with: 'Once upon a time, there was a post.'
    click_on 'Save Post'

    expect(page).to have_content('Post updated.')
    expect(page).to have_content('Once upon a time, there was a post.')

    click_on 'Delete'
	expect(page).to have_content('Post deleted.')
    expect(page).not_to have_content('An Post')

    visit '/'
    expect(page).not_to have_content('An Post')
  end
end
```

If you're like me, this is a bit hard to understand at a glance. As such, I like to extract methods to really emphasize what is in the tour.

```ruby
RSpec.describe 'Post management' do
  it 'supports creating, viewing, editing, and deleting' do
    add_post('An Post', 'An post body.')
    see_post_created('An Post', 'An post body.')
    
    edit_post('Once upon a time, there was a post.')
	see_post_updated('An Post', 'Once upon a time, there was a post.')

    delete_post('An Post')
	see_post_deleted('An Post')
  end

  def add_post(title, body)
    visit '/'
    click_on title
    fill_in 'Title', with: title
    fill_in 'Body', with: body
    click_on 'Create Post'
  end

  def edit_post(body)
    visit '/'
    click_on title
    click_on 'Edit'
    fill_in 'Body', with: body
    click_on 'Save Post'
  end

  def delete_post(title)
    visit '/'
    click_on title
    click_on 'Delete'
  end
    
  def see_post_created(title, body)
    expect(page).to have_content('Post created.')
    see_post(title, body)
  end

  def see_post_updated(title, body)
    expect(page).to have_content('Post updated.')
    see_post(title, body)
  end

  def see_post_deleted(title)
    expect(page).to have_content('Post deleted.')
    expect(page).not_to have_content(title)
   	visit '/'
    expect(page).not_to have_content(title)
  end

  def see_post(title, body)
    expect(page).to have_content(title)
    expect(page).to have_content(body)
  end
end
```

You may noticed some interesting things about this approach. First, the order of the steps in the tour is very important. For example, you can't very well _see_ a post until it exists. So for a CRUD feature, very often your tour will end up in the namesake's order: create, read, update, delete.

But most importantly this tour is entirely agnostic of the implementation details of the system. It's only dependencies are the text and links on the page. It's _content_ focused. This is also useful when it comes to making visual changes to an app that should not affect behavior.

## Speed

As a final observation, I would like to mention that this style of testing may lead to a faster test suite. It's true, these style of tests can be _very_ slow. In the context of web, they often involve some sort of browser automation that just takes time to setup and teardown. Therefore, the fewer times you have to do this the better off you are.

## Summary

While there are pros and cons on both sides of this approach, the truth is it's often very difficult to maintain these ideals. I believe the real benefit is a strong emphasis on closely considering any implementation coupling that you are introducing to an acceptance test. Such coupling will lead to brittleness and churn in the example, limiting its value over time and frustrating developers.