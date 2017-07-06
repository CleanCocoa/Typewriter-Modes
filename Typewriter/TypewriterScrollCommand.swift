//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

struct TypewriterScrollCommand {

    let textView: TypewriterTextView
    let lineRect: NSRect

    func performScroll() {

        textView.moveHighlight(rect: textView.superview!
            .convert(lineRect, from: textView)
            .offsetBy(dx: 0, dy: textView.textContainerInset.height))
        textView.scroll(lineRect.origin)
        textView.needsDisplay = true // or else scrolling is jagged
    }
}

struct TypewriterScrollPreparation {

    let textView: TypewriterTextView
    let layoutManager: NSLayoutManager

    func lineRect() -> NSRect {

        let location = textView.selectedRange().location

        if location >= layoutManager.numberOfGlyphs,
            layoutManager.extraLineFragmentRect != NSRect.zero {
            return layoutManager.extraLineFragmentRect
        }

        let insertionPointGlyphIndex = min(location, layoutManager.numberOfGlyphs - 1)

        return layoutManager.lineFragmentRect(forGlyphAt: insertionPointGlyphIndex, effectiveRange: nil)
    }

    func scrollCommand() -> TypewriterScrollCommand {

        return TypewriterScrollCommand(
            textView: textView,
            lineRect: self.lineRect())
    }
}
