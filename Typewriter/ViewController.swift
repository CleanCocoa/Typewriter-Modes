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
        let rect = self.boundingRect(selectedRange: affectedCharRange)
        let halfScreen = scrollView.bounds.height / 2
        var bottom = rect.origin
//            .applying(CGAffineTransform(translationX: 0, y: -halfScreen)) // not needed with container insets?
        if replacementString == "\n" {
            bottom.y += textView.layoutManager!.defaultLineHeight(for: textView.font!)
        }
        textView.scroll(bottom)
        return true
    }

    func boundingRect(selectedRange range: NSRange) -> NSRect {
        guard let layoutManager = textView.layoutManager,
            let textContainer = textView.textContainer
            else { preconditionFailure() }
        let activeRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        return layoutManager.boundingRect(forGlyphRange: activeRange, in: textContainer)
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
