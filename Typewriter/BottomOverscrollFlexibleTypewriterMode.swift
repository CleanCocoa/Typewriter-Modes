//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

class BottomOverscrollFlexibleTypewriterMode: FlexibleTypewriterMode, DrawsTypewriterLineHighlight {

    var configuration: OverscrollConfiguration = OverscrollConfiguration.zero

    private(set) var focusLockOffset: CGFloat = 0

    func proposeFocusLockOffset(_ offset: CGFloat) -> CGFloat {
        focusLockOffset = offset
        return offset
    }

    func adjustOverscrolling(
        containerBounds rect: NSRect,
        lineHeight: CGFloat) {

        let halfScreen = floor((rect.height - lineHeight) / 2)
        configuration.textContainerInset = NSSize(width: 0, height: halfScreen)
        configuration.overscrollTopOffset = halfScreen
    }

    func typewriterScrolled(_ point: NSPoint) -> NSPoint {

        return point.applying(.init(translationX: 0, y: -focusLockOffset))
    }


    // MARK: - Typewriter Highlight

    var highlight: NSRect = NSRect.zero

    func moveHighlight(rect: NSRect) {
        highlight = rect
    }

    func drawHighlight(in rect: NSRect) {
        NSColor(calibratedRed: 1, green: 1, blue: 0, alpha: 1).set()
        NSRectFill(highlight)
    }

    func hideHighlight() {
        highlight = NSRect.zero
    }
}
