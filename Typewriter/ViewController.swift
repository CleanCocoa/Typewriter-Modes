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
        textView.textContainerInset = NSSize(width: 0, height: scrollView.bounds.height)
    }

    func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
        let rect = self.boundingRect(selectedRange: affectedCharRange)
        let halfScreen = scrollView.bounds.height / 2
        textView.scroll(rect.origin.applying(CGAffineTransform(translationX: 0, y: +halfScreen)))
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
