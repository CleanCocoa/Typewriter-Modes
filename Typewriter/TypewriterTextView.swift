//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

class TypewriterTextView: NSTextView, OverscrollConfigurable {

    var typewriterMode: TypewriterMode? = BottomOverscrollFlexibleTypewriterMode()

    var isDrawingTypingHighlight = true

    override func drawBackground(in rect: NSRect) {
        super.drawBackground(in: rect)

        guard isDrawingTypingHighlight else { return }
        typewriterMode?.drawHighlight(in: rect)
    }

    func hideHighlight() {
        typewriterMode?.hideHighlight()
    }

    /// Move line highlight to `rect` in terms of the text view's coordinate system.
    /// Translates `rect` to take into account the `textContainer` position.
    func moveHighlight(rectInTextView rect: NSRect) {
        guard let rectInSuperview = self.superview?
            .convert(rect, from: self) else { return }
        moveHighlight(rect: rectInSuperview
            .offsetBy(dx: 0, dy: 0))
    }

    private func moveHighlight(rect: NSRect) {
        guard isDrawingTypingHighlight else { return }
        typewriterMode?.moveHighlight(rect: rect)
    }

    func moveHighlight(by distance: CGFloat) {
        guard let highlight = typewriterMode?.highlight else { return }
        moveHighlight(rect: highlight.offsetBy(dx: 0, dy: distance))
    }

    private var focusLockOffset: CGFloat {
        get { return typewriterMode?.focusLockOffset ?? 0 }
        set {
            let oldValue = focusLockOffset
            typewriterMode?.focusLockOffset = newValue

            guard newValue != oldValue else { return }

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
        let newOffset = ceil(-(textContainerInset.height - overscrollTopFlush) + distance)

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

    /// Amount of pixels to nudge the text up so it's flush with the top edge.
    var overscrollTopFlush: CGFloat = 0

    override var textContainerOrigin: NSPoint {
        let origin = super.textContainerOrigin
        return origin.applying(.init(translationX: 0, y: -overscrollTopFlush))
    }

    func scrollViewDidResize(_ scrollView: NSScrollView) {

        typewriterMode?.adjustOverscrolling(
            configurable: self,
            containerBounds: scrollView.bounds, // TODO: .contentView.documentVisibleRect ??
            lineHeight: self.lineHeight)
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

        guard let scrolledPoint = typewriterMode?.typewriterScrolled(point) else { return }
        self.enclosingScrollView?.contentView.bounds.origin = scrolledPoint
    }
}
