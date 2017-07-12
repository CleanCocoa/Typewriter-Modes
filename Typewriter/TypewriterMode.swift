//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation

protocol OverscrollConfigurable: class {
    var textContainerInset: NSSize { get set }
    var overscrollTopFlush: CGFloat { get set }
}

protocol TypewriterMode {

    var highlight: NSRect { get }
    func hideHighlight()
    func moveHighlight(rect: NSRect)
    func drawHighlight(in rect: NSRect)

    var focusLockOffset: CGFloat { get set }
    func adjustOverscrolling(configurable: OverscrollConfigurable, containerBounds rect: NSRect, lineHeight: CGFloat)
    func typewriterScrolled(_ point: NSPoint) -> NSPoint
}

extension TypewriterMode {
    func hideHighlight() {
        moveHighlight(rect: NSRect.zero)
    }
}
