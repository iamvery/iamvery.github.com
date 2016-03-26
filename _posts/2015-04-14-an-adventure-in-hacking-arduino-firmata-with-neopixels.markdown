---
layout: post
title: An Adventure in Hacking Arduino Firmata with NeoPixels
description: If you are using NeoPixels with Artoo, you might try https://github.com/iamvery/artoo-neopixel.
canonical: https://www.bignerdranch.com/blog/an-adventure-in-hacking-arduino-firmata-with-neopixels/
tags:
- ruby
- arduino
---

Learn ALL the things! That's basically the motto at Big Nerd Ranch. And in my last post, I wrote about how my team, The Artists Formally Known As (╯°□°)╯︵ ɥsɐןɔ, [learned a lot](https://www.bignerdranch.com/blog/hacking-arduino-firmata-with-neopixels/) of new things when we tackled hardware hacking with [Arduino][arduino], [NeoPixels][neopixel] and [Artoo][artoo].

Arduino is a great platform for beginning to learning about hardware. If you're into Ruby, you
might checkout Artoo, a robotics framework supporting a myriad of
platforms, including Arduino. During our Clash project, my team and I wanted to use Artoo
with NeoPixels, but there was no integration.

So we fixed it!

![learn all the things](/img/blog/2015/04/learn-all-the-things.png)

## `artoo-neopixel`

We packaged our integration between NeoPixels and Artoo into [a rubygem][artoo-neopixel]
for your hacking convenience.

### Firmata

First, you need to prepare the Arduino by uploading [our custom Firmata][custom-firmata]. This extends the Standard Firmata to add protocols for setting up and
communicating with NeoPixels. To get started:

* Open the Arduino IDE.
* Copy the [custom Firmata](https://github.com/iamvery/artoo-neopixel/blob/master/firmata/StandardFirmata-NeoPixel.ino) from Github.
* Upload it to your device.

![arduino ide](/img/blog/2015/04/arduino-firmata.png)

If you need more help with setting up the Arduino, check out [their guides][arduino-guides].

### RubyGem

Next, install our gem. This extends Artoo with support for NeoPixel LED strips
and matrices.

{% highlight bash %}
$ gem install artoo-neopixel
{% endhighlight %}

### Blinky Lights

Now you just need to write something magical. Here's an example script for a
[NeoPixel 40 RGB LED Matrix][neopixel-matrix] that will light up your room:

{% highlight ruby %}
# example.rb
require "artoo"
require "artoo-neopixel"

# Update the below port with your device's port
ARDUINO_PORT = "/dev/cu.usbmodem1411"

connection :arduino, adaptor: :firmata, port: ARDUINO_PORT

MATRIX_WIDTH = 5
MATRIX_HEIGHT = 8

device(
  :matrix,
  driver: :neomatrix,
  pin: 6,
  width: MATRIX_WIDTH,
  height: MATRIX_HEIGHT,
)

work do
  # You should see a bunch of blinky, beautiful lights! WOWOW
  loop do
    # Generate some random coordinates
    x = (MATRIX_WIDTH * rand).round
    y = (MATRIX_HEIGHT * rand).round

    # Generate some random RGB values between 0 and 100
    red = (100 * rand).round
    green = (100 * rand).round
    blue = (100 * rand).round

    matrix.on(x, y, red, green, blue)

    # the matrix sometimes need a little time to keep up
    sleep 0.01
  end
end
{% endhighlight %}

Run it and enjoy!

{% highlight bash %}
$ ruby example.rb
{% endhighlight %}

If you've played with Artoo at all, this will be completely familiar to you.
Either way, there isn't too much going on here, but the resulting strobe of
blinky colors is quite satisfying!

<blockquote class="twitter-video" lang="en" data-status="hidden">
  <p><a href="http://t.co/q1YY52asBw">pic.twitter.com/q1YY52asBw</a></p>&mdash; Jay Hayes (@iamvery)
  <a href="https://twitter.com/iamvery/status/575628248115245056">March 11, 2015</a>
</blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

## Hack on!

We're thankful to be able to open source this work. If you catch any gaping
memory leaks or anything at all, feel free to [open an issue][new-issue].

What will you make? Show us in the comments!

[clash]: http://www.bignerdranch.com/blog/fourth-annual-clash-of-the-coders
[arduino]: http://www.arduino.cc
[chae]: http://www.bignerdranch.com/about-us/nerds/chae-okeefe
[neopixel]: http://www.adafruit.com/category/168
[artoo]: http://artoo.io
[firmata]: http://firmata.org
[digital-pin]: http://arduino.cc/en/Tutorial/DigitalPins
[sysex-message]: http://firmata.org/wiki/V2.2ProtocolDetails#Sysex_Message_Format
[artoo-neopixel]: https://github.com/iamvery/artoo-neopixel
[new-issue]: https://github.com/iamvery/artoo-neopixel/issues/new
[custom-firmata]: https://github.com/iamvery/artoo-neopixel/blob/master/firmata/StandardFirmata-NeoPixel.ino
[arduino-getting-started]: http://arduino.cc/en/Guide/HomePage
[neopixel-matrix]: http://www.adafruit.com/product/1430
