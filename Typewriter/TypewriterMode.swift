//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation

struct OverscrollConfiguration {
    
    static var zero: OverscrollConfiguration {
        return OverscrollConfiguration(
            textContainerInset: NSSize.zero,
            textOriginOffset: 0,
            overscrollTopFlush: 0)
    }

    var textContainerInset: NSSize
    var textOriginOffset: CGFloat
    var overscrollTopFlush: CGFloat

    init(
        textContainerInset: NSSize,
        textOriginOffset: CGFloat,
        overscrollTopFlush: CGFloat) {

        self.textContainerInset = textContainerInset
        self.textOriginOffset = textOriginOffset
        self.overscrollTopFlush = overscrollTopFlush
    }
}

protocol TypewriterMode {

    var configuration: OverscrollConfiguration { get }
    var focusLockOffset: CGFloat { get }
    func adjustOverscrolling(containerBounds rect: NSRect, lineHeight: CGFloat)
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
