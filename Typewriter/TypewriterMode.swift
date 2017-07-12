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
    func adjustOverscrolling(containerSize size: NSSize, lineHeight: CGFloat)
    func typewriterScrolled(convertPoint point: NSPoint, scrollPosition: NSPoint) -> NSPoint
}

extension TypewriterMode {
    func typewriterScrolled(convertPoint point: NSPoint, scrollPosition: NSPoint) -> NSPoint {
        return point
    }
}

protocol FlexibleTypewriterMode: TypewriterMode {
    func proposeFocusLockOffset(_ offset: CGFloat, block: (_ newLock: CGFloat, _ oldLock: CGFloat) -> Void)
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
