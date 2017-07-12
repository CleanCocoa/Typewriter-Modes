//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

class FixedTypewriterMode: TypewriterMode {

    var highlight: NSRect {
        set { highlightWithOffset = newValue.offsetBy(dx: 0, dy: focusLockOffset) }
        get { return highlightWithOffset.offsetBy(dx: 0, dy: -focusLockOffset) }
    }
    fileprivate var highlightWithOffset: NSRect = NSRect.zero

    func moveHighlight(rect: NSRect) {
        highlight = rect
    }

    func drawHighlight(in rect: NSRect) {
        NSColor(calibratedRed: 1, green: 1, blue: 0, alpha: 1).set()
        NSRectFill(highlightWithOffset)
    }

    func hideHighlight() {
        highlight = NSRect.zero
    }

    var configuration: OverscrollConfiguration = OverscrollConfiguration.zero

    private var topOverscrollInset: CGFloat = 0
    var focusLockOffset: CGFloat {
        set { }
        get { return topOverscrollInset }
    }

    /// Cached (top) inset to position the highlighter.
    private var overscrollInset: CGFloat = 0

    func adjustOverscrolling(
        containerBounds rect: NSRect,
        lineHeight: CGFloat) {

        let halfScreen = floor((rect.height - lineHeight) / 2)
        configuration.textContainerInset = NSSize(width: 0, height: halfScreen)

        // Put focus lock 20% above the center
        let topFlush = rect.height * 0.2
        configuration.overscrollTopFlush = topFlush
        self.topOverscrollInset = halfScreen - topFlush
    }

    func typewriterScrolled(_ point: NSPoint) -> NSPoint {

        return point
    }
}
