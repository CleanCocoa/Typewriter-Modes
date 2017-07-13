//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

public class BottomOverscrollFlexibleTypewriterMode: FlexibleTypewriterMode, DrawsTypewriterLineHighlight {

    public init() { }

    private(set) public var configuration: OverscrollConfiguration = OverscrollConfiguration.zero

    private var focusLockOffset: CGFloat = 0

    public func proposeFocusLockOffset(_ offset: CGFloat, block: (CGFloat, CGFloat) -> Void) {
        let oldValue = focusLockOffset
        focusLockOffset = offset
        block(oldValue, offset)
    }

    public func adjustOverscrolling(
        containerSize size: NSSize,
        lineHeight: CGFloat) {

        let halfScreen = floor((size.height - lineHeight) / 2)
        configuration.textContainerInset = NSSize(width: 0, height: halfScreen)
        configuration.overscrollTopOffset = halfScreen
    }

    public func typewriterScrolled(convertPoint point: NSPoint, scrollPosition: NSPoint) -> NSPoint {

        return point.applying(.init(translationX: 0, y: -focusLockOffset))
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
