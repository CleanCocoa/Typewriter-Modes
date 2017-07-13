//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

public class TypewriterTextView: NSTextView {

    public var typewriterMode: TypewriterMode? = nil {
        didSet {
            guard let scrollView = self.enclosingScrollView else { return }
            relayoutTypewriterMode(scrollView: scrollView)
        }
    }

    /// Amount of pixels to nudge the text up, e.g. to be flush with the top edge.
    private var overscrollTopOffset: CGFloat { return typewriterMode?.configuration.overscrollTopOffset ?? 0 }
    private var textOriginInset: CGFloat { return typewriterMode?.configuration.textOriginInset ?? 0 }

    /// Cache to prevent coordinate conversion
    private var lastInsertionPointY: CGFloat?

    public func lockTypewriterDistance() {

        guard typewriterMode is FlexibleTypewriterMode else { return }

        let screenInsertionPointRect = firstRect(forCharacterRange: selectedRange(), actualRange: nil)
        guard screenInsertionPointRect.origin.y != lastInsertionPointY else { return }
        self.lastInsertionPointY = screenInsertionPointRect.origin.y

        guard let windowInsertionPointRect = window?.convertFromScreen(screenInsertionPointRect) else { return }
        guard let enclosingScrollView = self.enclosingScrollView else { return }

        let insertionPointRect = enclosingScrollView.convert(windowInsertionPointRect, from: nil)
        let distance = insertionPointRect.origin.y
            - enclosingScrollView.frame.origin.y
            // Take care of scroll view borders and content insets
            - enclosingScrollView.contentView.frame.origin.y
        let newOffset = ceil(-(textContainerInset.height - overscrollTopOffset) + distance)

        self.proposeFocusLockOffset(newOffset)
    }

    private func proposeFocusLockOffset(_ offset: CGFloat) {

        guard let flexibleTypewriterMode = typewriterMode as? FlexibleTypewriterMode else { return }

        flexibleTypewriterMode.proposeFocusLockOffset(offset) { newValue, oldValue in

            guard newValue != oldValue else { return }

            let difference = newValue - oldValue
            self.typewriterScroll(by: difference)
            self.fixInsertionPointPosition()
            self.moveHighlight(by: difference)
        }
    }

    public func unlockTypewriterDistance() {

        self.proposeFocusLockOffset(0)
        self.lastInsertionPointY = nil
    }

    /// After changing the `textContainerOrigin`, the insertion point sometimes
    /// remains where it was, not moving with the text.
    private func fixInsertionPointPosition() {
        self.setSelectedRange(selectedRange())
        self.needsDisplay = true
    }

    public override var textContainerOrigin: NSPoint {
        let origin = super.textContainerOrigin
        return origin.applying(.init(translationX: 0, y: textOriginInset - overscrollTopOffset))
    }

    public func relayoutTypewriterMode(scrollView: NSScrollView) {

        defer { forceLayoutWithNewInsets() }

        guard let typewriterMode = self.typewriterMode else {
            self.textContainerInset = .zero
            return
        }

        typewriterMode.adjustOverscrolling(
            containerSize: scrollView.contentView.documentVisibleRect.size,
            lineHeight: self.lineHeight)
        self.textContainerInset = typewriterMode.configuration.textContainerInset
    }

    public override var textContainerInset: NSSize {
        didSet {
            // Scroll so much that the text does not jump in the view when
            // adding/removing the top inset.
            let delta = oldValue.height - textContainerInset.height
            typewriterScroll(by: -delta)
        }
    }

    /// Sends an "edited" message to the layout manager to make it adjust the size
    /// to fit the `textContainerInset`. Without doing this, it'll take until after
    /// the next edit by the user.
    private func forceLayoutWithNewInsets() {
        self.textStorage?.edited(.editedAttributes, range: selectedRange(), changeInLength: 0)
    }

    internal var lineHeight: CGFloat {
        guard let font = self.font,
            let layoutManager = self.layoutManager
            else { return 0 }

        return layoutManager.defaultLineHeight(for: font)
    }

    public func typewriterScroll(by offset: CGFloat) {

        guard let visibleRect = enclosingScrollView?.contentView.documentVisibleRect else { return }
        let point = visibleRect.origin
            .applying(.init(translationX: 0, y: offset))
        typewriterScroll(to: point)
    }

    public func typewriterScroll(to point: NSPoint) {

        guard let enclosingScrollView = self.enclosingScrollView else { return }
        let scrollPosition = enclosingScrollView.contentView.bounds.origin
        guard let scrolledPoint = typewriterMode?.typewriterScrolled(convertPoint: point, scrollPosition: scrollPosition) else { return }
        enclosingScrollView.contentView.bounds.origin = scrolledPoint

        // Fix jagged scrolling artifacts
        self.needsDisplay = true
    }


    // MARK: - Typewriter Highlight

    public var isDrawingTypingHighlight = true

    var highlightDrawer: DrawsTypewriterLineHighlight? { return typewriterMode as? DrawsTypewriterLineHighlight }

    public override func drawBackground(in rect: NSRect) {
        super.drawBackground(in: rect)

        guard isDrawingTypingHighlight else { return }
        highlightDrawer?.drawHighlight(in: rect)
    }

    public func hideHighlight() {
        highlightDrawer?.hideHighlight()
    }

    /// Move line highlight to `rect` in terms of the text view's coordinate system.
    /// Translates `rect` to take into account the `textContainer` position.
    public func moveHighlight(rectInTextView rect: NSRect) {
        guard let rectInSuperview = self.superview?
            .convert(rect, from: self) else { return }
        moveHighlight(rect: rectInSuperview)
    }

    private func moveHighlight(rect: NSRect) {
        guard isDrawingTypingHighlight else { return }
        highlightDrawer?.moveHighlight(rect: rect)
    }
    
    public func moveHighlight(by distance: CGFloat) {
        guard let highlight = highlightDrawer?.highlight else { return }
        moveHighlight(rect: highlight.offsetBy(dx: 0, dy: distance))
    }
}
