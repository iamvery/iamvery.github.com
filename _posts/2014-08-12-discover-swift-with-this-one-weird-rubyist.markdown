---
layout: post
author: Jay Hayes
date: 2014-08-12 08:10:22+00:00
title: 'Discover Swift with this One Weird Rubyist!'
categories:
- iOS
- Ruby
- Swift
---

Originally posted on the [Big Nerd Ranch Blog](http://www.bignerdranch.com/blog/discover-swift-with-this-one-weird-rubyist).

---

At Big Nerd Ranch, we love certain things. We love coffee, we love fitness and we
_really_ love technology. When Apple announced [Swift](https://developer.apple.com/swift), I found it really hard to
resist cracking open the
[free](https://itunes.apple.com/us/book/the-swift-programming-language/id881256329?mt=11&ls=1)
[books](https://itunes.apple.com/us/book/using-swift-cocoa-objective/id888894773?mt=11&ls=1)
and seeing what it's all about.

I write Ruby every day and love the language, and
there's a lot for a Rubyist to love here. Apple's cooking up something special.

## Getting Started

With Swift, Apple introduced [playgrounds](https://developer.apple.com/library/prerelease/ios/recipes/xcode_help-source_editor/ExploringandEvaluatingSwiftCodeinaPlayground/ExploringandEvaluatingSwiftCodeinaPlayground.html), a way of getting inline feedback from code as it's typed into Xcode.
This is really helpful in discovering the language, because you can jump to the
documentation in Xcode and really get down to business.

### Swift CLI

Apple included a Swift
[REPL](http://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop) in
their Xcode 6 betas. Additionally, scripts provided as arguments will be run
with "immediate execution."

The usage is pretty simple. If you run the command, you get the Swift REPL:

~~~
% xcrun swift
Welcome to Swift!  Type :help for assistance.
  1>
~~~

If you reference a Swift file, it will compile and run it:

~~~
% xcrun swift harvey.swift
I am the batman!
~~~

I like to keep an alias in my environment:

{% highlight sh %}
alias swift="xcrun swift"
{% endhighlight %}

Apple seems to be investing in Swift as a scripting language as well. You can
even "shebang" Swift scripts. Check out Apple's ["Files and Initialization"](https://developer.apple.com/swift/blog/?id=7) blog post.

![thumbs up]({{ site.baseurl }}/img/blog/2014/08/computering-kid-thumbs-up.gif)

## Constant Change

Swift makes the distinction between constant and variable values during
assignment. In Ruby, we indicate constant values by naming their identifier
with a capital first letter. By convention, we use ALL CAPS for constants and
CamelCase for types. Any other identifier is a variable value.

{% highlight ruby %}
WOW_GREAT_DEV = 'Jay'
Dev = Struct.new(:name)

dev = Dev.new(WOW_GREAT_DEV)
puts dev.name
# Jay

WOW_GREAT_DEV = 'Dog' # this produces a warning

dev = Dev.new("Dog")
puts dev.name
# Dog
{% endhighlight %}

Constant and variable values in Swift are created using the `let` and `var`
keywords respectively.

{% highlight swift %}
let wowGreatDev = "Jay"

struct Dev {
  var name: String
}

var dev = Dev(name: wowGreatDev)
println(dev.name)
# Jay

wowGreatDev = "Dog" // this produces an error

dev = Dev(name: "Dog")
println(dev.name)
{% endhighlight %}

## Tuples

Tuples are a great, low-ceremony way of passing around a collection of related
values. They allow us to collect things into a compound value. Unlike other
structures in Swift, they don't have much behavior.

### Value Collections

In Ruby, we will sometimes use a `Hash` to collect related values. Consider an
options hash in Ruby:

{% highlight ruby %}
def process(options = {})
  puts options.fetch(:force, false)
  puts options.fetch(:format, :json)
end

process
process(force: true, format: :html)
# false
# :json
# true
# :html
{% endhighlight %}

We might reach for a tuple in Swift to do something similar. A notable
difference is that we must explicitly state the valid options:

{% highlight swift %}
func process(options: (force: Bool, format: String) = (force: false, format: "json")) {
  println(options.force)
  println(options.format)
}
process()
process(options: (force: true, format: "html"))
// false
// "json"
// true
// "html"
{% endhighlight %}

Notice one difference is that the Swift implementation uses an "external
parameter" to set the `options` parameter to the method.

### Destructured Assignment

In both Ruby and Swift, certain values may be destructured during assignment to
multiple variables. As long as the grouping on the left matches the structure
on the right, the collection is destructured to match. This may be done with
arrays in Ruby:

{% highlight ruby %}
x,(y,z) = [1,[2,3]]
puts x
puts y
puts z
# 1
# 2
# 3
{% endhighlight %}

Similarly, Swift tuples can be destructured during assignment:

{% highlight swift %}
let (x,(y,z)) = (1,(2,3))
println(x)
println(y)
println(z)
// 1
// 2
// 3
{% endhighlight %}

Another example of Ruby destructuring is as parameters to a message call.

{% highlight ruby %}
foo = lambda do |(x,(y,z))|
  puts x
  puts y
  puts z
end

bar = [1,[2,3]]
foo.call(bar)
# 1
# 2
# 3
{% endhighlight %}

Unlike Ruby, Swift argument lists are not treated the same as assignment. To
destructure an argument in Swift, it must be done using assignment in the body
of the method or closure:

{% highlight swift %}
let foo = { bar: (Int, (Int, Int)) in
  let (x,(y,z)) = bar
  println(x)
  println(y)
  println(z)
}

bar = (1,(2,3))
foo(bar)
// 1
// 2
// 3
{% endhighlight %}

## Value Bindings

Another interesting feature of Swift is _value bindings_. In combination with a
`switch` statement, you can execute separate blocks of code based on the
destructured state of a tuple. You can even add conditions to the statements to
direct matches further. The canonical example is directing execution by
anchoring parts of a `point` tuple:

{% highlight swift %}
func printPoint(point: (Int, Int)) {
  switch point {
  case (let x, 0):
    println("x: \(x)")
  case (0, let y):
    println("y: \(y)")
  case (let x, let y) where x == y:
    println("Both x and y: \(x)")
  case (let x, let y):
    println("x: \(x), y: \(y)")
  }
}

printPoint((2,0))
printPoint((3,3))
printPoint((1,2))
// x: 2
// Both x and y: 3
// x: 1, y: 2
{% endhighlight %}

The first case is matched because the destructured tuple matches where its
second part is equal. Its first part is set to a constant and made available in
the scope of the case block. The second call matches the third case due to the
additional `where` condition being met.

Here's a solution I came up with in Ruby. The syntax is a bit more involved,
because Ruby doesn't have the value binding syntactic sugar of Swift:

{% highlight ruby %}
def print_point(point)
  case point
  when ->((_,y)) { y.zero? }
    puts "x: #{point[0]}"
  when ->((x,_)) { x.zero? }
    puts "y: #{point[1]}"
  when ->((x,y)) { x == y }
    puts "Both x and y: #{point[0]}"
  else
    puts "x: #{point[0]}, y: #{point[1]}"
  end
end

print_point([2,0])
print_point([3,3])
print_point([1,2])
# x: 2
# Both x and y: 3
# x: 1, y: 2
{% endhighlight %}

This example uses a lambda to match each case. This works because Ruby
overrides Proc's `===` operator as an alias to `call`.

## Enums as a State Machine

In Ruby, enums aren't a thing. We're generally cool with that. We tend to
reach for namespaced constant values to mimic the most basic behavior of enums
as collections of values.

Swift introduces `enum` as a value type and allows us to add behavior to them.
An interesting side effect is that enumerations in Swift may be used as state
machines:

{% highlight swift %}
enum TrafficLight: String {
  case Red = "STOP", Yellow = "WHOA", Green = "GO"

  mutating func next() {
    switch self {
    case Red: self = Green
    case Yellow: self = Red
    case Green: self = Yellow
    }

    println("The light has changed...")
  }
}

var light = TrafficLight.Green

println("You approach a traffic light...")
println(light.toRaw())
light.next()
println(light.toRaw())
light.next()
println(light.toRaw())
// You approach a traffic light...
// GO
// The light has changed...
// WHOA
// The light has changed...
// STOP
{% endhighlight %}

The ability to wrap the state transition logic into a single type is pretty
cool. This type might be used in collaboration with other objects that
observe the current value without care of how and when transitions are made.

Ruby's lack of "enum" as a concept leads to more code, but it's not indicative
of a problem per se. I opted to keep the usage as similar to the Swift
implementation as possible, providing class methods for each state. Also, this
implementation is without dependency outside Ruby's stdlib. It may be worth
checking out the [`state_machine` gem](https://github.com/pluginaweek/state_machine)
amongst [others](https://www.ruby-toolbox.com/categories/state_machines).

{% highlight ruby %}
class TrafficLight
  COLORS = [RED = "STOP", YELLOW = "WHOA", GREEN = "GO"]

  def self.Red
    new(RED)
  end

  def self.Yellow
    new(YELLOW)
  end

  def self.Green
    new(GREEN)
  end

  attr_reader :state

  def initialize(state)
    @state = state
  end

  def next
    @state = case state
      when RED then GREEN
      when YELLOW then RED
      when GREEN then YELLOW
    end

    puts 'The light has changed...'
  end
end

light = TrafficLight.Green

puts 'You approach a traffic light...'
puts light.state
light.next
puts light.state
light.next
puts light.state
# You approach a traffic light...
# GO
# The light has changed...
# WHOA
# The light has changed...
# STOP
{% endhighlight %}

## Consider Demeter

"Optional types" are a particularly interesting and important feature of Swift.
Optionals allow Swift to have strong type safety, while also being compatible
with existing Objective-C frameworks that may respond with `nil`.  Due to their
explicitness, optional types are an arguably more expressive way of indicating
that a value may be missing.

One aspect of optionals does concern me. Some examples the Swift book
illustrate how optionals can be used to ignore chained method calls if any of
the values in the chain are nil:

{% highlight swift %}
// assume we have a reference to a `widget` object
let tophat = widget.foo?.bar?.tophat
// say tophat is nil, why?
{% endhighlight %}

My warning is that optional chainings enable some nested Law of Demeter
violations. In the above example, there is no way to know what in the chain of
things turned out to be nil, we just know there's no `tophat` in the end.

In the Rails world, this is very similar to the `try` method which allows you
to attempt to send messages to an object that might be nil.

{% highlight ruby %}
# assume `widget` is a valid message in scope
widget.try(:foo).try(:bar).try(:tophat)
# say tophat is nil, why?
{% endhighlight %}

I'm not familiar enough with the Apple development ecosystem to make a
statement against optional types in Swift—heck, every variable in Ruby is
"optional." My point is to highlight the risk for your code to lose confidence
and become tightly coupled to a hierarchy of objects.

Optional types are a tool like anything else. You may build a masterpiece; you
may cut your arm off.

## Always Learning

Playing with Swift over the past few weeks has been a lot of fun. Ruby
developers should feel pretty comfortable in the language. A number of modern
syntaxes have been included, which increases its approachability. Apple has made it
pretty clear that things could change drastically before its first release, but
the direction they're taking it is exciting.

By the way, [we teach](http://www.bignerdranch.com/we-teach) incredible classes
on this stuff! Check out [our offerings](https://training.bignerdranch.com/classes)
(including [Ruby!](https://training.bignerdranch.com/classes/ruby-on-the-server))
and come learn with me.
