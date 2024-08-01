### Love2talk

Love2talk is a small include, optimized for the Löve2D game engine, allowing you to speak using text to speech. It currently supports Windows and Mac OS platforms. On Windows, the Tolk library is used, providing speech either through the most popular screen readers or SAPI 5 if none are running, while on Mac the system's default speech voice will be used.

### How to use

Clone this repository with the --recurse-submodules switch to download the objC module needed for Mac support. Then, in your code simply require the library:

`tts=require "Love2talk"`

Then just use the say function to speak some text, optionally setting the interrupt parameter to true if you want whatever you're about to speak to interrupt whatever's being spoken now (useful for speaking menus or keys causing information to be spoken)

```tts.say("Hello, world!", true)```

There is also a `isSpeaking()` function that will return either true or false depending on if something is being spoken, however screen readers don't support checking whether they're speaking or not so this shouldn't be relied on for timing.

I have also provided a main.lua example file that you can run with love that will speak some text when any key is pressed, which you can use for testing.

On Windows, you will also need to either download or compile the talk library as well as the interface libraries for the various screen readers. Because the Tolk CI system and official downloads appear to be broken, I have put the official Tolk distribution I used to develop this include on my website [here](https://piotrs.site/tolk.zip)
### Limitations and known issues

As mentioned above, the `isSpeaking` function only works if SAPI or the Mac speech is used, due to how screen readers work. Additionally, on Mac OS the interrupt speech parameter is ignored and new text will always interrupt what's being spoken. I'll try to fix this in the future, but pull requests are also welcome.