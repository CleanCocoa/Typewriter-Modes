//
//  ViewController.swift
//  Typewriter
//
//  Created by Christian Tietze on 03.07.17.
//  Copyright © 2017 Christian Tietze. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextViewDelegate, NSLayoutManagerDelegate {

    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet var textView: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.string = try! String(contentsOf: URL(fileURLWithPath: "/Users/ctm/Archiv/§ O reswift.md"))
        textView.textContainerInset = NSSize(width: 0, height: scrollView.bounds.height / 2)
        textView.layoutManager?.delegate = self
    }

    func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {

        guard let textContainer = textContainer else { return }
        guard let characterRange = self.pendingTypingChangeRange else { return }
        self.pendingTypingChangeRange = nil

        let activeRange = layoutManager.glyphRange(forCharacterRange: characterRange, actualCharacterRange: nil)
        let rect = layoutManager.boundingRect(forGlyphRange: activeRange, in: textContainer)
        let bottom = rect.origin
        textView.scroll(bottom)
    }

    var pendingTypingChangeRange: NSRange?

    func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {

        guard let text = replacementString else { return true }

        let expectedLength = text.isEmpty ? 0 : affectedCharRange.length + text.nsLength
        pendingTypingChangeRange = NSRange(
            location: affectedCharRange.location + expectedLength,
            length: 0)

        return true
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
