//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

class FinalFantasyTypewriterMode: TypewriterMode, DrawsTypewriterLineHighlight {

    var configuration: OverscrollConfiguration = OverscrollConfiguration.zero

    private var threshold: CGFloat = 0
    var focusLockOffset: CGFloat { return threshold }

    func adjustOverscrolling(
        containerSize size: NSSize,
        lineHeight: CGFloat) {

        let halfScreen = floor((size.height - lineHeight) / 2)
        configuration.textContainerInset = NSSize(width: 0, height: halfScreen)
        configuration.overscrollTopOffset = halfScreen

        // Put focus lock threshold at 60% down the view
        self.threshold = size.height * 0.6
    }

    func typewriterScrolled(convertPoint point: NSPoint, scrollPosition: NSPoint) -> NSPoint {

        let currentY = scrollPosition.y
        let insertionY = point.y

        guard insertionY > currentY + threshold else { return scrollPosition }

        return point.applying(.init(translationX: 0, y: -threshold))
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
