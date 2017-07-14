# Typewriter Text View

For many years, the Mac platform has pioneered minimal writing apps. Apart from the distraction-free full-screen modes, popular writing apps sport a "typewriter mode". 

Typewriter scrolling means: the text insertion point always maintains the same vertical distance to the window edges when you type. If you hit "enter", the document is supposed to move up one line so the insertion point stays fixed. This is a nice effect when you write because your eyes don't need to move that much. They can focus on one line as you type and the document goes out of the way. It's called "typewriter scrolling" because a typewriter punches letters at the same spot, moving the paper around.

## Typewriter Modes

The sample app supports a few different typewriter modes.

### Fixed

Fixed typewriter mode is the most simple:

* You, the developer, decide where the line of the insertion point is placed. When the mode is enabled, the text view is locked to that predefined location.
* If the user moves around with the arrow keys, clicks or scrolls around, the app behaves regularly, like TextEdit. The document does _not_ scroll to center on the new insertion point. Only when the user types does the document center on the line again.

The insertion point is relative to the window edges. It should be in the most comfortable position. Assuming your app is going to be used in full-screen mode or at least taking up most of the vertical space of the screen, you can think of window height and screen height as almost always being equal. Looking at what `NSWindow.center()` does, placing a window not at the vertical center but slightly above it, I suggest you do the same for a more pleasing experience. Compute the distance whenever the parent `NSScrollView` changes and keep it at somewhere between 35%--45% of the scroll view's height from the top.

When you figure this out once, you're done and it'll just work: user enables typewriter mode, insertion point is moved to the expected position and stays put.

This mode is easy to understand because the fixed on-screen position always behaves the same. It's easy to make predictions even for newbies.


### True

Due to a lack of better terms, "True Typewriter Mode" is what I call a fixed mode with a few tweaks. The insertion point always stays where it is, that means:

* Pressing the "up" arrow key scrolls the document down 1 line. In absolute screen coordinates, the insertion point did not move. The document beneath it moved.
* Similarly, scrolling with the trackpad or mouse wheel moves the document around and moves the insertion point with it. 

I call this "true" because that's what a real typewriter does. You can move the paper around to focus on another line, but the insertion point location changes with it.

This mode always keeps the insertion point in place on-screen. There's no difference between scrolling and using the arrow keys to move the insertion point around. You cannot scroll per-pixel but only per-line. The scrolling movement is very jagged this way, like aliens from Space Invaders coming closer. This mode may be useful to give a special kind of uninterrupted focus to your app's users. But it's mostly suited for composing, not editing text, because scrolling around in a document isn't smooth and creates a lot of visual noise.

**At the moment, this repository does not have an example for this.**


### Flexible

This mode doesn't have a fixed on-screen position for the insertion point. It's called "flexible" because any position can become the locked 

* Wherever the user places the insertion point (with mouse or arrow keys), that position is locked to becomes the new insertion point location.
* Scrolling does not affect the insertion point or the locked distance relative to the window edges, unlike "True Typewriter Mode". When you scroll away and then press a key to type, you're taken back to the place where you've been before, like in a regular TextEdit session.

This gives the user of your app the most freedom to decide how much space to the top (and bottom) of the screen should be maintained by the app. Vertically centering the insertion point is useful and pleasant to just be typing away and users can do that at will. Keeping the insertion point locked further to the top means that the bottom part stays put on-screen. That's useful for some scenarios; if you put a list of topics below your insertion point, this to-do list will stay on screen while you write. As a downside, this flexible behavior is harder to predict at first and chances are your users will like a fixed approach better because its results are more predictable. Scrolling the document and moving the insertion point where you like it best is fiddly.

## Base Techniques

I explain the parts in blog posts instead of making the readme even longer:

* [Overscrolling](http://cleancocoa.com/posts/2017/07/typewriter-mode-overscrolling/)


## Contributing

There's still work to do to make all typewriter modes a pleasant experience. I'd love to see you involved! 

For technical details, have a look at the [Contributing Guide](/CONTRIBUTING.md).

## License

Copyright (c) 2017 Christian Tietze. Distributed under the MIT License.
