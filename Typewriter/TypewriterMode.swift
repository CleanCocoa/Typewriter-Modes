//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation

struct OverscrollConfiguration {
    
    static var zero: OverscrollConfiguration {
        return OverscrollConfiguration(
            textContainerInset: NSSize.zero,
            textOriginInset: 0,
            overscrollTopOffset: 0)
    }

    var textContainerInset: NSSize
    var textOriginInset: CGFloat
    var overscrollTopOffset: CGFloat

    init(
        textContainerInset: NSSize,
        textOriginInset: CGFloat,
        overscrollTopOffset: CGFloat) {

        self.textContainerInset = textContainerInset
        self.textOriginInset = textOriginInset
        self.overscrollTopOffset = overscrollTopOffset
    }
}

protocol TypewriterMode {

    var configuration: OverscrollConfiguration { get }
    var focusLockOffset: CGFloat { get }
    func adjustOverscrolling(containerSize size: NSSize, lineHeight: CGFloat)
    func typewriterScrolled(_ point: NSPoint) -> NSPoint
}

protocol FlexibleTypewriterMode: TypewriterMode {
    /// - returns: Adjusted `offset` that will be used as focus lock.
    func proposeFocusLockOffset(_ offset: CGFloat) -> CGFloat
}

protocol DrawsTypewriterLineHighlight {

    var highlight: NSRect { get }
    func hideHighlight()
    func moveHighlight(rect: NSRect)
    func drawHighlight(in rect: NSRect)
}

extension DrawsTypewriterLineHighlight {
    func hideHighlight() {
        moveHighlight(rect: NSRect.zero)
    }
}
