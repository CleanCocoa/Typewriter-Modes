//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

public class FinalFantasyTypewriterMode: TypewriterMode, DrawsTypewriterLineHighlight {

    public init() { }

    private(set) public var configuration: OverscrollConfiguration = OverscrollConfiguration.zero

    private var focusLockThreshold: CGFloat = 0

    public func adjustOverscrolling(
        containerSize size: NSSize,
        lineHeight: CGFloat) {

        let halfScreen = floor((size.height - lineHeight) / 2)
        configuration.textContainerInset = NSSize(width: 0, height: halfScreen)
        configuration.overscrollTopOffset = halfScreen

        // Put focus lock threshold at 60% down the view
        self.focusLockThreshold = size.height * 0.6
    }

    public func typewriterScrolled(convertPoint point: NSPoint, scrollPosition: NSPoint) -> NSPoint {

        let currentY = scrollPosition.y
        let insertionY = point.y

        guard insertionY > currentY + focusLockThreshold else { return scrollPosition }

        return point.applying(.init(translationX: 0, y: -focusLockThreshold))
    }


    // MARK: - Typewriter Highlight

    public var highlight: NSRect = NSRect.zero

    public func moveHighlight(rect: NSRect) {
        highlight = rect
    }

    public func drawHighlight(in rect: NSRect) {
        NSColor(calibratedRed: 1, green: 1, blue: 0, alpha: 1).set()
        NSRectFill(highlight)
    }
    
    public func hideHighlight() {
        highlight = NSRect.zero
    }
}
