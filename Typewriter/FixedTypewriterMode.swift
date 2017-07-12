//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

class FixedTypewriterMode: TypewriterMode, DrawsTypewriterLineHighlight {

    var configuration: OverscrollConfiguration = OverscrollConfiguration.zero

    private(set) var focusLockOffset: CGFloat = 0

    func adjustOverscrolling(
        containerSize size: NSSize,
        lineHeight: CGFloat) {

        let halfScreen = floor((size.height - lineHeight) / 2)
        configuration.textContainerInset = NSSize(width: 0, height: halfScreen)

        // Put focus lock 20% above the center
        let topFlush = size.height * 0.2
        configuration.overscrollTopOffset = topFlush
        self.focusLockOffset = halfScreen - topFlush
    }

    
    // MARK: - Typewriter Highlight

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
}
