//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

public class FixedTypewriterMode: TypewriterMode, DrawsTypewriterLineHighlight {

    public init() { }

    private(set) public var configuration: OverscrollConfiguration = OverscrollConfiguration.zero

    private var focusLockOffset: CGFloat = 0

    public func adjustOverscrolling(
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

    public var highlight: NSRect {
        set { highlightWithOffset = newValue.offsetBy(dx: 0, dy: focusLockOffset) }
        get { return highlightWithOffset.offsetBy(dx: 0, dy: -focusLockOffset) }
    }
    fileprivate var highlightWithOffset: NSRect = NSRect.zero

    public func moveHighlight(rect: NSRect) {
        highlight = rect
    }

    public func drawHighlight(in rect: NSRect) {
        NSColor(calibratedRed: 1, green: 1, blue: 0, alpha: 1).set()
        NSRectFill(highlightWithOffset)
    }

    public func hideHighlight() {
        highlight = NSRect.zero
    }
}
