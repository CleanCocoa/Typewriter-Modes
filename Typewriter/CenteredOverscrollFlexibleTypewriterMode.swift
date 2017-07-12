//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

class CenteredOverscrollFlexibleTypewriterMode: TypewriterMode {

    var highlight: NSRect {
        set { highlightWithOffset = newValue.offsetBy(dx: 0, dy: focusLockOffset) }
        get { return highlightWithOffset.offsetBy(dx: 0, dy: -focusLockOffset) }
    }
    fileprivate var highlightWithOffset: NSRect = NSRect.zero

    func moveHighlight(rect: NSRect) {
        highlight = rect.offsetBy(dx: 0, dy: overscrollInset)
    }

    func drawHighlight(in rect: NSRect) {

        NSColor(calibratedRed: 1, green: 1, blue: 0, alpha: 1).set()
        NSRectFill(highlightWithOffset)
    }

    func hideHighlight() {
        highlight = NSRect.zero
    }

    var configuration: OverscrollConfiguration = OverscrollConfiguration.zero

    var focusLockOffset: CGFloat = 0 {
        didSet {
            configuration.textOriginOffset = focusLockOffset
        }
    }

    private var overscrollInset: CGFloat = 0

    func adjustOverscrolling(
        containerBounds rect: NSRect,
        lineHeight: CGFloat) {

        let halfScreen = floor((rect.height - lineHeight) / 2)
        configuration.textContainerInset = NSSize(width: 0, height: halfScreen)
        configuration.overscrollTopFlush = 0

        self.overscrollInset = halfScreen
    }

    func typewriterScrolled(_ point: NSPoint) -> NSPoint {

        // Container inset includes adding an offset to the scrolled point automatically.
        return point
    }
}
