//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation

public struct OverscrollConfiguration {

    public static var zero: OverscrollConfiguration {
        return OverscrollConfiguration(
            textContainerInset: NSSize.zero,
            textOriginInset: 0,
            overscrollTopOffset: 0)
    }

    public var textContainerInset: NSSize
    public var textOriginInset: CGFloat
    public var overscrollTopOffset: CGFloat

    public init(
        textContainerInset: NSSize,
        textOriginInset: CGFloat,
        overscrollTopOffset: CGFloat) {

        self.textContainerInset = textContainerInset
        self.textOriginInset = textOriginInset
        self.overscrollTopOffset = overscrollTopOffset
    }
}

public protocol TypewriterMode {

    var configuration: OverscrollConfiguration { get }
    func adjustOverscrolling(containerSize size: NSSize, lineHeight: CGFloat)
    func typewriterScrolled(convertPoint point: NSPoint, scrollPosition: NSPoint) -> NSPoint
}

extension TypewriterMode {
    public func typewriterScrolled(convertPoint point: NSPoint, scrollPosition: NSPoint) -> NSPoint {
        return point
    }
}

public protocol FlexibleTypewriterMode: TypewriterMode {
    func proposeFocusLockOffset(_ offset: CGFloat, block: (_ newLock: CGFloat, _ oldLock: CGFloat) -> Void)
}

public protocol DrawsTypewriterLineHighlight {

    var highlight: NSRect { get }
    func hideHighlight()
    func moveHighlight(rect: NSRect)
    func drawHighlight(in rect: NSRect)
}

extension DrawsTypewriterLineHighlight {
    public func hideHighlight() {
        moveHighlight(rect: NSRect.zero)
    }
}
