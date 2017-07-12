//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

class TypewriterTextView: NSTextView {

    var typewriterMode: TypewriterMode? = nil {
        didSet {
            guard let scrollView = self.enclosingScrollView else { return }
            relayoutTypewriterMode(scrollView: scrollView)
            fixInsertionPointPosition()
        }
    }

    /// Amount of pixels to nudge the text up to be flush with the top edge.
    private var overscrollTopInset: CGFloat { return typewriterMode?.configuration.overscrollTopOffset ?? 0 }
    private var textOriginInset: CGFloat { return typewriterMode?.configuration.textOriginInset ?? 0 }
    private var focusLockOffset: CGFloat { return typewriterMode?.focusLockOffset ?? 0 }

    func proposeFocusLockOffset(_ offset: CGFloat) {

        guard let flexibleTypewriterMode = typewriterMode as? FlexibleTypewriterMode else { return }

        let oldValue = focusLockOffset
        let newValue = flexibleTypewriterMode.proposeFocusLockOffset(offset)

        guard newValue != oldValue else { return }

        let difference = newValue - oldValue
        self.typewriterScroll(by: difference)
        self.fixInsertionPointPosition()
        self.moveHighlight(by: difference)
    }

    /// Cache to prevent coordinate conversion
    private var lastInsertionPointY: CGFloat?

    func lockTypewriterDistance() {

        guard typewriterMode is FlexibleTypewriterMode else { return }

        let screenInsertionPointRect = firstRect(forCharacterRange: selectedRange(), actualRange: nil)
        guard screenInsertionPointRect.origin.y != lastInsertionPointY else { return }
        self.lastInsertionPointY = screenInsertionPointRect.origin.y

        guard let windowInsertionPointRect = window?.convertFromScreen(screenInsertionPointRect) else { return }
        guard let enclosingScrollView = self.enclosingScrollView else { return }

        let insertionPointRect = enclosingScrollView.convert(windowInsertionPointRect, from: nil)
        let distance = insertionPointRect.origin.y - enclosingScrollView.frame.origin.y - enclosingScrollView.contentView.frame.origin.y
        let newOffset = ceil(-(textContainerInset.height - overscrollTopInset) + distance)

        self.proposeFocusLockOffset(newOffset)
    }

    func unlockTypewriterDistance() {

        self.proposeFocusLockOffset(0)
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
        return origin.applying(.init(translationX: 0, y: textOriginInset - overscrollTopInset))
    }

    func relayoutTypewriterMode(scrollView: NSScrollView) {

        guard let typewriterMode = self.typewriterMode else {
            self.textContainerInset = .zero
            return
        }

        typewriterMode.adjustOverscrolling(
            containerSize: scrollView.contentView.documentVisibleRect.size,
            lineHeight: self.lineHeight)
        self.textContainerInset = typewriterMode.configuration.textContainerInset
        // TODO: scroll view does not update content height until resizing the window or typing something
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

        guard let enclosingScrollView = self.enclosingScrollView else { return }
        let scrollPosition = enclosingScrollView.contentView.bounds.origin
        guard let scrolledPoint = typewriterMode?.typewriterScrolled(convertPoint: point, scrollPosition: scrollPosition) else { return }
        enclosingScrollView.contentView.bounds.origin = scrolledPoint
    }


    // MARK: - Typewriter Highlight

    var isDrawingTypingHighlight = true

    var highlightDrawer: DrawsTypewriterLineHighlight? { return typewriterMode as? DrawsTypewriterLineHighlight }

    override func drawBackground(in rect: NSRect) {
        super.drawBackground(in: rect)

        guard isDrawingTypingHighlight else { return }
        highlightDrawer?.drawHighlight(in: rect)
    }

    func hideHighlight() {
        highlightDrawer?.hideHighlight()
    }

    /// Move line highlight to `rect` in terms of the text view's coordinate system.
    /// Translates `rect` to take into account the `textContainer` position.
    func moveHighlight(rectInTextView rect: NSRect) {
        guard let rectInSuperview = self.superview?
            .convert(rect, from: self) else { return }
        moveHighlight(rect: rectInSuperview)
    }

    private func moveHighlight(rect: NSRect) {
        guard isDrawingTypingHighlight else { return }
        highlightDrawer?.moveHighlight(rect: rect)
    }

    func moveHighlight(by distance: CGFloat) {
        guard let highlight = highlightDrawer?.highlight else { return }
        moveHighlight(rect: highlight.offsetBy(dx: 0, dy: distance))
    }
}
