//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

/// Overscrolls in both directions.
class FullOverscrollFlexibleTypewriterMode: TypewriterMode {

    let heightProportion: CGFloat

    /// - parameter heightProportion: Normalized fraction of te screen to overscroll. Defaults to `1.0`.
    init(heightProportion: CGFloat = 1.0) {
        self.heightProportion = max(0.0, min(heightProportion, 1.0))
    }

    var highlight: NSRect {
        set { highlightWithOffset = newValue.offsetBy(dx: 0, dy: focusLockOffset) }
        get { return highlightWithOffset.offsetBy(dx: 0, dy: -focusLockOffset) }
    }
    fileprivate var highlightWithOffset: NSRect = NSRect.zero

    func moveHighlight(rect: NSRect) {
        highlight = rect.offsetBy(dx: 0, dy: overscrollInset)
    }

    func drawHighlight(in rect: NSRect) {

        NSColor(calibratedRed: 1, green: 1, blue: 0, alpha: 1).set()
        NSRectFill(highlightWithOffset)
    }

    func hideHighlight() {
        highlight = NSRect.zero
    }

    var configuration: OverscrollConfiguration = OverscrollConfiguration.zero

    var focusLockOffset: CGFloat = 0 {
        didSet {
            configuration.textOriginOffset = focusLockOffset
        }
    }

    /// Cached (top) inset to position the highlighter.
    private var overscrollInset: CGFloat = 0

    func adjustOverscrolling(
        containerBounds rect: NSRect,
        lineHeight: CGFloat) {

        let screenPortion = floor((rect.height - lineHeight) * heightProportion)
            - 2 * heightProportion // magic extra offset to ensure the last line is fully visible at 100% overscrolling
        configuration.textContainerInset = NSSize(width: 0, height: screenPortion)
        configuration.overscrollTopFlush = 0

        self.overscrollInset = screenPortion
    }

    func typewriterScrolled(_ point: NSPoint) -> NSPoint {

        // Container inset includes adding an offset to the scrolled point automatically.
        return point
    }
}
