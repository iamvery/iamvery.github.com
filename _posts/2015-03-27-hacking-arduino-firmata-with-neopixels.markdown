---
layout: post
title: Hacking Arduino Firmata with NeoPixels
excerpt: As part of our Clash of the Coders, one team tackled hardware hacking with Arduino, NeoPixels and Artoo.
canonical: https://www.bignerdranch.com/blog/hacking-arduino-firmata-with-neopixels
---

We recently had our annual app-building competition, [Clash of the Coders][clash].
It's a fantastic opportunity for us nerds to experiment with unfamiliar
technologies, stretching ourselves and our tools. It's all about learning, a
fundamental value of Big Nerd Ranch. After an intense 72-hour coding marathon,
our team (_The Artists Formally Known As (╯°□°)╯︵ ɥsɐןɔ_, yep) came out with
an online, multiplayer game equipped with clients crossing four platforms: iOS,
Android, Web... and Arduino!

## The Clash

Our project was a great opportunity to get familiar with hardware. Thanks to
the kindness of fellow nerd [Chae O'Keefe][chae], we had plenty
of [Arduino][arduino] hardware and the brilliant idea to incorporate
individually addressable [NeoPixels][neopixel], maximizing the aesthetic of our
physical client 😄.

![arduino client](/img/blog/2015/03/arduino-client.jpg)

Eventually, we settled on using [Artoo][artoo], a robotics framework written in
Ruby, to communicate with the Arduino. We chose it because of our familiarity with
Ruby (and by the time we got around to working on the Arduino client there was
only seven hours left in the competition).

Unfortunately, we quickly hit a showstopper. Artoo communicates with Arduino
hardware using the [Firmata][firmata] protocol. Firmata doesn't have support
built in for NeoPixels.

So the adventure began...

## Serial for Breakfast

In the early hours of the last day of our competition, we began peeling back
the layers of software used to communicate between Artoo and Firmata. We
quickly figured out that communication with Firmata is done with specially
formatted serial messages containing command bytes. These bytes indicate the
purpose of the message, such as a write to a [digital pin][digital-pin].

![gh screenshot](/img/blog/2015/03/gh-screenshot.png)

Thankfully, the Firmata designers had the forethought to consider others'
desires to extend the protocol. This is accomplished via [SysEx messages][sysex-message],
interestingly [part of the MIDI standard][sysex-midi]. By defining custom
SysEx commands, we were able to send special messages to Firmata which were
received, triggering routines to setup and control NeoPixels!

## Hack on!

We had an absolute blast this year! If you're interested in the nitty gritty
details, check out my upcoming post, out next week. And don't forget to show us what you make in the comments below!


[clash]: https://www.bignerdranch.com/blog/clash-of-the-coders-winners-2015/
[arduino]: http://www.arduino.cc
[chae]: http://www.bignerdranch.com/about-us/nerds/chae-okeefe
[neopixel]: http://www.adafruit.com/category/168
[artoo]: http://artoo.io
[firmata]: http://firmata.org
[digital-pin]: http://arduino.cc/en/Tutorial/DigitalPins
[sysex-message]: http://firmata.org/wiki/V2.2ProtocolDetails#Sysex_Message_Format
[sysex-midi]: http://electronicmusic.wikia.com/wiki/System_exclusive
[new-issue]: https://github.com/iamvery/artoo-neopixel/issues/new
