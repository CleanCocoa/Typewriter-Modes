//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

/// Overscrolls in both directions.
public class FullOverscrollFlexibleTypewriterMode: FlexibleTypewriterMode, DrawsTypewriterLineHighlight {

    let heightProportion: CGFloat

    /// - parameter heightProportion: Normalized fraction of the screen to overscroll.
    ///   Defaults to `1.0` (100% overscrolling).
    public init(heightProportion: CGFloat = 1.0) {
        self.heightProportion = max(0.0, min(heightProportion, 1.0))
    }

    private(set) public var configuration: OverscrollConfiguration = OverscrollConfiguration.zero

    private var focusLockOffset: CGFloat = 0 {
        didSet {
            configuration.textOriginInset = focusLockOffset
        }
    }

    public func proposeFocusLockOffset(_ offset: CGFloat, block: (CGFloat, CGFloat) -> Void) {
        let oldValue = focusLockOffset
        focusLockOffset = offset
        block(oldValue, offset)
    }

    /// Cached (top) inset to position the highlighter.
    private var overscrollInset: CGFloat = 0

    public func adjustOverscrolling(
        containerSize size: NSSize,
        lineHeight: CGFloat) {

        let screenPortion = floor((size.height - lineHeight) * heightProportion)
            // magic extra offset to ensure the last line is fully visible at 100% overscrolling
            - 2 * heightProportion
        configuration.textContainerInset = NSSize(width: 0, height: screenPortion)
        configuration.overscrollTopOffset = 0

        self.overscrollInset = screenPortion
    }


    // MARK: - Typewriter Highlight

    fileprivate var highlightWithOffset: NSRect = NSRect.zero

    public var highlight: NSRect {
        set { highlightWithOffset = newValue.offsetBy(dx: 0, dy: focusLockOffset) }
        get { return highlightWithOffset.offsetBy(dx: 0, dy: -focusLockOffset) }
    }

    public func moveHighlight(rect: NSRect) {
        highlight = rect.offsetBy(dx: 0, dy: overscrollInset)
    }

    public func drawHighlight(in rect: NSRect) {

        NSColor(calibratedRed: 1, green: 1, blue: 0, alpha: 1).set()
        NSRectFill(highlightWithOffset)
    }

    public func hideHighlight() {
        highlight = NSRect.zero
    }
}
