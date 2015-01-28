---
layout: post
title: Unit Testing JavaScript
excerpt: I tend to lean heavily on TDD to realize the design of my objects. I recently
  had to jump into some JavaScript and wanted the same advantage while writing
  it.
---

**TL;DR** - I had to learn myself to unit test JavaScript recently. I made [a repository](https://github.com/iamvery/js-unit-testing-example)
to illustrate my findings.

---

I tend to lean heavily on TDD to realize the design of objects. I recently
had to jump into some JavaScript and wanted the same advantage while writing
it. I found it tricky to come about a unit testing setup, so this is the
result of my afternoon experimenting. I'm fairly pleased with the result, but
I wouldn't trust it as idiomatic.

## The Things

### Node.js

The goto whenever you want to run JavaScript outside of the browser. I'm
running this test suite from the command line.

### Jasmine

The test framework I settled on is [Jasmine](http://jasmine.github.io).
Currently, I really like the [RSpec](https://relishapp.com/rspec) style of
writing tests, and this scratches that itch in JavaScript world.

### Grunt

I'm a command line guy, so I really want to be able to run these tests
["headless"](http://phantomjs.org/headless-testing.html). [Grunt](http://gruntjs.com)
is a JavaScript task runner that has [a jasmine plugin](https://github.com/gruntjs/grunt-contrib-jasmine)
for headless test runs.

To use Grunt on the command line, I also need to install the [grunt-cli](https://github.com/gruntjs/grunt-cli)
library.

## Setup

### Node.js

If you use [Homebrew](http://brew.sh), the Node.js install is straight forward:

    $ brew install node

### Node Modules

Once node is installed, I use `npm` ("node package manager") to install
the JavaScript dependencies. These are stored in a file named `package.json` in
the root directory of your project. Here are the dependencies for our simple
test suite:

<script src="http://gist-it.appspot.com/https://github.com/iamvery/js-unit-testing-example/blob/master/package.json"></script>

Install the JavaScript dependencies:

    $ npm install

### Create Gruntfile.js

This file configures the Grunt task runner. Here is a simple configuration:

<script src="http://gist-it.appspot.com/https://github.com/iamvery/js-unit-testing-example/blob/master/Gruntfile.js"></script>

This file looks for JavaScript files in the `./lib` directory and finds spec
files named `*Spec.js` in the `./spec/lib` directory.

## Run the suite

I skipped over adding specs in this post. Checkout [my example repo](https://github.com/iamvery/js-unit-testing-example)
for a simple, complete example. You can run the test suite with this command:

    $ grunt jasmine

You should see output like:

    Running "jasmine:tappy" (jasmine) task
    Testing jasmine specs via PhantomJS

     Thing
       ✓ does stuff

    1 spec in 0.004s.
    >> 0 failures

    Done, without errors.

## That's all, folks

Let me know if you have any questions in the comments! I may not know the
answer, but I love opportunities to learn!
