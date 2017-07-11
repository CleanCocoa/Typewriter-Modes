//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

class TypewriterTextView: NSTextView {

    var isDrawingTypingHighlight = true
    var highlight: NSRect {
        set { highlightWithOffset = newValue.offsetBy(dx: 0, dy: focusLockOffset) }
        get { return highlightWithOffset.offsetBy(dx: 0, dy: -focusLockOffset) }
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

    /// Move line highlight to `rect` in terms of the text view's coordinate system.
    /// Translates `rect` to take into account the `textContainer` position.
    func moveHighlight(rectInTextView rect: NSRect) {
        guard let rectInSuperview = self.superview?
            .convert(rect, from: self) else { return }
        moveHighlight(rect: rectInSuperview
            .offsetBy(dx: 0, dy: textContainerInset.height))
    }

    private func moveHighlight(rect: NSRect) {
        guard isDrawingTypingHighlight else { return }
        highlight = rect
    }

    func moveHighlight(by distance: CGFloat) {
        moveHighlight(rect: highlight.offsetBy(dx: 0, dy: distance))
    }

    private var focusLockOffset: CGFloat = 0 {
        didSet {
            guard focusLockOffset != oldValue else { return }
            let difference = focusLockOffset - oldValue
            self.typewriterScroll(by: difference)
            self.fixInsertionPointPosition()
            self.moveHighlight(by: difference)
        }
    }

    /// Cache to prevent coordinate conversion
    private var lastInsertionPointY: CGFloat?

    func lockTypewriterDistance() {

        let screenInsertionPointRect = firstRect(forCharacterRange: selectedRange(), actualRange: nil)
        guard screenInsertionPointRect.origin.y != lastInsertionPointY else { return }
        self.lastInsertionPointY = screenInsertionPointRect.origin.y

        guard let windowInsertionPointRect = window?.convertFromScreen(screenInsertionPointRect) else { return }
        guard let enclosingScrollView = self.enclosingScrollView else { return }

        let insertionPointRect = enclosingScrollView.convert(windowInsertionPointRect, from: nil)
        let distance = insertionPointRect.origin.y - enclosingScrollView.frame.origin.y - enclosingScrollView.contentView.frame.origin.y
        let newOffset = ceil(-(textContainerInset.height) + distance)

        self.focusLockOffset = newOffset
    }

    func unlockTypewriterDistance() {
        
        self.focusLockOffset = 0
        self.lastInsertionPointY = nil
    }

    /// After changing the `textContainerOrigin`, the insertion point sometimes
    /// remains where it was, not moving with the text.
    private func fixInsertionPointPosition() {
        self.setSelectedRange(selectedRange())
        self.needsDisplay = true
    }

    override var textContainerOrigin: NSPoint {
        let origin = super.textContainerOrigin
        return origin.applying(.init(translationX: 0, y: focusLockOffset))
    }

    func scrollViewDidResize(_ scrollView: NSScrollView) {

        let halfScreen = floor((scrollView.bounds.height - lineHeight) / 2)
        textContainerInset = NSSize(width: 0, height: halfScreen)
    }

    var lineHeight: CGFloat {
        guard let font = self.font,
            let layoutManager = self.layoutManager
            else { return 0 }

        return layoutManager.defaultLineHeight(for: font)
    }

    func typewriterScroll(by offset: CGFloat) {

        guard let visibleRect = enclosingScrollView?.contentView.documentVisibleRect else { return }
        let point = visibleRect.origin
            .applying(.init(translationX: 0, y: offset))
        typewriterScroll(to: point)
    }

    func typewriterScroll(to point: NSPoint) {

        self.enclosingScrollView?.contentView.bounds.origin = point
    }
}
