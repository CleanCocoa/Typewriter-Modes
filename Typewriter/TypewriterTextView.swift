//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

class TypewriterTextView: NSTextView {

    var isDrawingTypingHighlight = true
    var highlight: NSRect {
        set { highlightWithOffset = newValue.offsetBy(dx: 0, dy: verticalOffset) }
        get { return highlightWithOffset.offsetBy(dx: 0, dy: -verticalOffset) }
    }
    var highlightWithOffset: NSRect = NSRect.zero

    override func drawBackground(in rect: NSRect) {
        super.drawBackground(in: rect)

        guard isDrawingTypingHighlight else { return }

        // TODO: highlight is not production-ready: resizing the container does not move the highlight and pasting strings spanning multiple line fragments, then typing a character shows 2 highlighters
        NSColor(calibratedRed: 1, green: 1, blue: 0, alpha: 1).set()
        NSRectFill(highlightWithOffset)
    }

    func hideHighlight() {
        highlight = NSRect.zero
    }

    func moveHighlight(rect: NSRect) {
        let oldDirtyRect = highlightWithOffset
        highlight = rect
        setNeedsDisplay(oldDirtyRect, avoidAdditionalLayout: true)
    }

    var verticalOffset: CGFloat = 0

    override var textContainerOrigin: NSPoint {
        let origin = super.textContainerOrigin
        return origin.applying(.init(translationX: 0, y: verticalOffset))
    }

    func scrollViewDidResize(_ scrollView: NSScrollView) {
        let lineHeight: CGFloat = {
            guard let font = self.font else { return 0 }
            guard let layoutManager = self.layoutManager else { return 0 }
            return layoutManager.defaultLineHeight(for: font)
        }()

        let halfScreen = scrollView.bounds.height / 2
        textContainerInset = NSSize(width: 0, height: halfScreen - lineHeight)
        verticalOffset = halfScreen / 2
    }
}
