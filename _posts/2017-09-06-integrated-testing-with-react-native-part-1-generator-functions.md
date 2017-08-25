---
layout: post
author: Jay Hayes
date: 2017-09-06 10:00:00+00:0)
title: "Integrated Testing with React Native, Part 1: Generator Functions"
description: Testing is critical for confidence in your work. For React Native, you must walk object trees. See how generator functions can help.
excerpt: In my recent experience, getting started with React Native testing is a little rough since tpopular tools aren't great for integrated testing. The first step is traversing the object tree of a rendered component. For that, generator functions are of great use!
tags:
- web
- native
canonical: https://www.bignerdranch.com/blog/integrated-testing-with-react-native-part-1-generator-functions/
---

Originally featured on the [Big Nerd Ranch Blog](https://www.bignerdranch.com/blog/integrated-testing-with-react-native-part-1-generator-functions/).

---

Love it or hate, JavaScript is everywhere. Recently, I took another step toward assimilation by attending the [Big Nerd Ranch Front-end Essentials](https://www.bignerdranch.com/training/courses/front-end-essentials/) bootcamp. And… all biases aside, IT WAS GREAT! I began the week with two goals:

1. How to even modern CSS?
2. React Native sounds cool, but how to test?

Thankfully, the answer to my first goal was "stop being lazy, Jay. [Learn flexbox](https://flexboxfroggy.com/)." The second part was a little more subtle, and I expanded upon the ideas that I had learned in class once I returned home. Throughout the next few posts on the topic, I'll explain my findings.

## Object Traversal

In my recent experience, getting started with React Native testing is a little rough. There are good tools for [snapshot testing](https://facebook.github.io/jest/docs/en/snapshot-testing.html) and [shallow rendering](http://airbnb.io/enzyme/docs/api/shallow.html), but I wanted something capable of deep rendering without the tight coupling of a full snapshot. To start, I began digging into the output of React's test renderer which is used with snapshot testing. As it turns out, the results of test rendering are a deeply-nested, often circular object tree.

The first hurdle in establishing a strategy for integrated component testing with React Native is picking out particular nodes in deeply nested object trees. The below screenshots illustrate this nesting. So for example, you might want to assert that certain text is found somewhere in the hierarchy. If you have any functional programming leanings, you may immediately think of this as a recursive problem, and to be honest, it's quite natural to reason about the problem recursively.

![React Native Diagram](/assets/img/blog/2017/09/rn-diagram.jpg)

Recursion is great, but it can be tricky to bail early on the routine if you're only interested in finding the first matching node. Not to mention the [complicated story](https://duckduckgo.com/html?q=javascript%20tail%20call%20optimization) with tail-call optimization in JavaScript. Modern JavaScript provides a useful tool for solving our traversal problem: [Generator Functions](https://www.bignerdranch.com/blog/generators-rick-astley-and-the-sequence-of-fibonacci/).

Take a moment to theorize the usage of such a generator function:

```javascript
let dom = {
  type: 'div',
  props: {
    className: 'main',
    children: [
      { type: 'h1', props: { children: 'Welcome to React!' } }
    ]
  }
}

let each = visit(dom) // This is your traversal generator!

for (let node of each) {
  console.log(node)
}
// { type: 'div', props: [Object] }
// 'div'
// { className: 'main', children: [Array] }
// 'main'
// [ [Object] ]
// { type: 'h1', props: [Object] }
// 'hi'
// { children: 'Welcome to React!' }
// 'Welcome to React!'
```

Since the return value of generators conform to the [iterable protocol](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Iteration_protocols#iterable), they can be used with the `for..of` construct! So how should the `visit()` function be implemented?

### Writing `visit()`

Here's your generator function signature. Don't forget the asterisk!

```javascript
function* visit(obj) {
  //
}
```

The data structures encountered in React Native are often _very_ deeply nested (and sometimes circular), so with that foresight it makes sense to implement `visit()` as a [breadth-first search](https://en.wikipedia.org/wiki/Breadth-first_search). To avoid recursion stack limits in JavaScript, revert back to good-ole looping. Initialize a `queue` with the subject of your search and loop until you're all out of nodes:

```javascript
function* visit(obj) {
  let queue = [obj], next
  while(queue.length > 0) {
    next = queue.shift()
    yield next
    // think of the children!
  }
}
```

Hurray, you have visited the first object, but the algorithm is incomplete. How can you visit each of its children?

To answer this question, consider the _types_ of children that must also be visited: arrays and objects. Take those into account:

```Javascript
function* visit(obj) {
  let queue = [obj], next
  while(queue.length > 0) {
    next = queue.shift()
    yield next
    if (Array.isArray(next)) {
      queue.push(...next)
    } else if(next instanceof Object) {
      queue.push(...Object.values(next))
    }
  }
}
```

So, if the `next` value in `queue` is an Array, add all its values to the array. Otherwise, if it's any sort of object, add all of its [_enumerable_ properties](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/keys) to the `queue`. The [spread operator (`...`) ](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Spread_operator) is particularly handy for this use.

That's it! You can now visit each node in any object graph. However, there are a couple more things to consider.

### API

For general use cases, it may not be desirable to require folks to deal with `visit()` directly. Instead, you might want to expose a more functional interface such as `each()`:

```javascript
var obj = {
  type: 'div'
  props: {}
}
each(obj, console.log)
// { type: 'div', props: {} }
// 'div'
// {}
```

Providing such an interface is very straight-forward:

```javascript
function each(obj, fn) {
  let visitor = visit(obj)
  for (let node of visitor) {
    fn(node)
  }
}
```

More interestingly, we can build on `visit()` to provide other common functions on collections. Take `find()` for example, which returns the first match without visiting the entire tree:

```javascript
function find(obj, match) {
  let each = visit(obj)
  for (let node of each) {
    if (match(node)) {
      return node
    }
  }
}

find({ foo: { bar: 'it me' } }, n => n.bar === 'it me')
// { bar: 'it me' }
```

You can imagine even more functions implemented in this way. Give `map()`, `count()`, and `select()` a try on your own!

### Circular References

There is one more edge case to consider. Circular references are trivially easy to create in JavaScript, and such an object would result in infinite looping with our current implementation of `visit()`:

```javascript
var obj = {}
obj.self = obj
each(obj, console.log) // THIS IS THE LOOP THAT NEVER ENDS
```

The issue is easily addressed by ensuring that the exact same node is never visited twice. You can accomplish this by keeping track of which nodes have been seen:

```Diff
 function* visit(obj) {
-  let queue = [obj], next
+  let queue = [obj], next, seen = new Set()
   while(queue.length > 0) {
     next = queue.shift()
+    if (seen.has(next)) { continue }
+    seen.add(next)
     yield next
     if (Array.isArray(next)) {
       queue.push(...next)
     } else if(next instanceof Object) {
       queue.push(...Object.values(next))
     }
   }
 }
```

Hurray, no more infinite loops!

## But... Testing?

Theory and generalizations are fun and all, but how can we use this practically? I promised to relate this to React Native testing. You'll have to look out for [the next post][next-post] to see how this all comes together. Stay tuned!

[next-post]: /2017/09/29/integrated-testing-with-react-native-part-2-minimize-coupling.html