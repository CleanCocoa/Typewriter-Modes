//
//  ViewController.swift
//  Typewriter
//
//  Created by Christian Tietze on 03.07.17.
//  Copyright © 2017 Christian Tietze. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextViewDelegate {

    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet var textView: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.string = try! String(contentsOf: URL(fileURLWithPath: "/Users/ctm/Archiv/§ O reswift.md"))
        textView.textContainerInset = NSSize(width: 0, height: scrollView.bounds.height / 2)
    }

    func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {

        guard let text = replacementString else { return true }

        let rect = self.boundingRect(selectedRange: affectedCharRange, text: text)
        let bottom = rect.origin
//            .applying(CGAffineTransform(translationX: 0, y: -halfScreen)) // not needed with container insets?
        textView.scroll(bottom)
        return true
    }

    func boundingRect(selectedRange range: NSRange, text: String) -> NSRect {

        guard
            let baseTextContainer = textView.textContainer,
            let baseTextStorage = textView.textStorage
            else { preconditionFailure() }

        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(containerSize: baseTextContainer.containerSize)
        layoutManager.addTextContainer(textContainer)
        defer { layoutManager.removeTextContainer(at: 0) }
        let textStorage = NSTextStorage(attributedString: baseTextStorage)
        textStorage.addLayoutManager(layoutManager)
        defer { textStorage.removeLayoutManager(layoutManager) }

        textStorage.replaceCharacters(in: range, with: text)
        let length = text.isEmpty ? 0 : range.length + text.nsLength
        let changeRange = NSRange(location: range.location + length, length: 0)
        let activeRange = layoutManager.glyphRange(forCharacterRange: changeRange, actualCharacterRange: nil)
        return layoutManager.boundingRect(forGlyphRange: activeRange, in: textContainer)
    }

}

extension String {
    var nsLength: Int {
        return (self as NSString).length
    }
}

extension NSTextView {

    var lineHeight: CGFloat {
        guard let font = self.font,
            let layoutManager = self.layoutManager
            else { return 0 }

        return layoutManager.defaultLineHeight(for: font)
    }
}

class TypewriterTextView: NSTextView { }
