---
layout: post
author: Jay Hayes
date: 2017-09-29 10:00:00+00:00
title: "Integrated Testing with React Native, Part 2: Minimize Coupling"
description: Testing is critical for confidence in your work. Using the generator function from the last post, build a testing strategy that is focused on content.
excerpt: Existing tools for testing React Native apps are deeply coupled to a component's rendered structure. By using the object traversal generator function from the last post, you can write tests that focus on content and stand up to changes that don't affect behavior.
tags:
- web
- native
canonical: https://www.bignerdranch.com/blog/integrated-testing-with-react-native-part-2-minimize-coupling/
---

Originally featured on the [Big Nerd Ranch Blog](https://www.bignerdranch.com/blog/integrated-testing-with-react-native-part-2-minimize-coupling/).

---

In the [last post][last-post], I promised to tell you how breadth-first object traversal came into play testing React Native apps. Today is the day!

As it turns out, unit testing React Native code is really no different than testing any other JavaScript, especially with [stateless, functional components][bnr-fp-components]. However, unit testing can only get you so far. Inevitably you need to confirm code works in integration. Unfortunately the options we have tend to feel a little heavy-handed with [snapspot testing][snapshot-testing] and [computer-driven UI tests][detox]. Snapshot tests are coupled very tightly the entire structure of a rendered component and thus tend to be brittle. UI tests are difficult to set up and run terribly slow.

Another option is using a tool like [Enzyme][enzyme] to make assertions about the VDOM output by the renderer. Unfortunately React Native only works with [shallow rendering][shallow-rendering]. It would be great have something resembling [full-dom rendering][full-dom] for React Native!

## What Is In a DOM?

Enzyme, [Jest][jest], and the like use React's test renderer to produce an in-memory, rendered DOM as a deeplying nested, often recursive JavaScript object tree. One such tree might resemble this:

```javascript
{
  type: 'View',
  props: [Object],
  children: [
    { type: 'Text', props: [Object], children: ['Just content.'] },
  ]
}
```

Thankfully, as we found out in the [last post][last-post], such a data structure is a breeze to traverse!

## The Tests

Take for example a component that has loading and error states. When data is available it displays each bit as an item in a list. Start by outlining your test cases:

- When data is loading, I see the message "Loading".
- When an error occurs, I see the error message.
- When data is loaded, I see each item's title on screen.

Using `visit` from the [last post][last-post], translate these cases into tests:

```javascript
import React from 'react'
import renderer from 'react-test-renderer'

import Widgets from './widgets'
import { visit } from './visit'

it('displays message when data is loading', () => {
  let data = { loading: true }
  let component = renderer.create(<Widgets data={data} />)
  let tree = component.toJSON()

  expect(content(tree)).toContain('Loading')
})

it('displays message when an error occurs', () => {
  let data = { error: { message: 'It broke.' } }
  let component = renderer.create(<Widgets data={data} />)
  let tree = component.toJSON()

  expect(content(tree)).toContain('It broke.')
})

it('displays item titles when data is loaded', () => {
  let data = { loading: false, items: [{ title: 'first'}, { title: 'second' }] }
  let component = renderer.create(<Widgets data={data} />)
  let tree = component.toJSON()

  let text = content(tree)
  expect(text).toContain('first')
  expect(text).toContain('second')
})

function content(tree) {
  let each = visit(tree)
  let content = []
  for (let node of nodes) {
    if (node && node.type === 'Text' && node.children) {
      content.push(node.children.join())
    }
  }
  return content.join()
}
```

These tests are written to be very loosely coupled to the structure of the component. All that matters is the tested content is _seen_ in the component. This is done by looking for all `Text` nodes and testing that the expected content is contained within them.

### The Component

To make these tests pass, you can write a relatively simple component.

```javascript
import React from 'react'
import { Text } from 'react-native'

let Widgets = ({ data: { loading, error, items } }) => {
  if (loading) {
    return <Text>Loading...</Text>
  }

  if (error) {
    return <Text>{error.message}</Text>
  }

  return (
    <Text>{items.map(i => i.title).join()}</Text>
  )
}

export default Widgets
```

This component is simple if not naive. However, from the tests' perspective it doesn't really matter how it's built so long as the little bits of text are seen. For example, this same component could be completely re-written in a functional style:

```javascript
import React from 'react'
import { Text } from 'react-native'
import { branch, compose, renderComponent } from 'recompose'

let Loading = () =>
  <Text>Loading...</Text>

let WithLoader = branch(
  ({ data: { loading } }) => loading,
  renderComponent(Loading),
)

let Error = ({ data: { error } }) =>
  <Text>{error.message}</Text>

let HandleError = branch(
  ({ data: { error } }) => error,
  renderComponent(Error),
)

let Widgets = ({ data: { items } }) =>
  <Text>{items.map(i => i.title).join()}</Text>

let enhance = compose(
  WithLoader,
  HandleError,
)

export default enhance(Widgets)
```

Which looks exactly the same, like this:

![](/assets/img/blog/2017/09/naive.jpg)

The tests still pass! Let's take things just a little bit further to really drive home the point. Update the `Widgets` component to use fancy, scrollable lists from [NativeBase][nativebase].

```diff
 import React from 'react'
 import { Text } from 'react-native'
+import { Container, Header, Body, Content, List, ListItem } from 'native-base'
 import { branch, compose, renderComponent } from 'recompose'

 let Loading = () =>
   <Text>Loading...</Text>

 let WithLoader = branch(
   ({ data: { loading } }) => loading,
   renderComponent(Loading),
 )

 let Error = ({ data: { error } }) =>
   <Text>{error.message}</Text>

 let HandleError = branch(
   ({ data: { error } }) => error,
   renderComponent(Error),
 )

 let Widgets = ({ data: { items } }) =>
-  <Text>{items.map(i => i.title).join()}</Text>
+  <Container>
+    <Header>
+      <Body>
+        <Text>Items</Text>
+      </Body>
+    </Header>
+    <Content>
+      <List dataArray={items}
+        renderRow={item =>
+          <ListItem>
+            <Text>{item.title}</Text>
+          </ListItem>
+        }>
+      </List>
+    </Content>
+  </Container>

 let enhance = compose(
   WithLoader,
   HandleError,
 )

 export default enhance(Widgets)
```

Look how much better it looks!

![](/assets/img/blog/2017/09/as-list.jpg)

Not only does it look better, but the tests _still_ pass without any changes! That is because the tests are written with a hyper-focus on _content_. The tests are sufficiently decoupled from the component structure so tests only fail when _behavior_ is broken!

## Wrapping Up

This style of testing is a powerful mechanism for validating content without writing tests that are frustratingly brittle (read: prone to false failures). However, it probably does not replace the role of [snapshots][snapshot-testing] which ensure that a stable component does not suffer regressions once it's in place.

What testing strategies have you developed for React and React Native?

[bnr-fp-components]: https://www.bignerdranch.com/blog/destroy-all-classes-turn-react-components-inside-out-with-functional-programming/
[snapshot-testing]: https://facebook.github.io/jest/docs/en/snapshot-testing.html
[detox]: https://github.com/wix/detox
[enzyme]: http://airbnb.io/enzyme/docs/
[shallow-rendering]: http://airbnb.io/enzyme/docs/api/shallow.html
[full-dom]: http://airbnb.io/enzyme/docs/api/mount.html
[jest]: https://facebook.github.io/jest/docs/en/tutorial-react-native.html
[native-base]: https://nativebase.io/
[last-post]: /2017/09/06/integrated-testing-with-react-native-part-1-generator-functions.html
