//
//  ViewController.swift
//  Typewriter
//
//  Created by Christian Tietze on 03.07.17.
//  Copyright © 2017 Christian Tietze. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextStorageDelegate {

    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet var textView: NSTextView!

    var highlighter: HighlightView!

    override func viewDidLoad() {
        super.viewDidLoad()

        highlighter = HighlightView(frame: NSRect.zero)
        textView.superview!.addSubview(highlighter)

        textView.string = try! String(contentsOf: URL(fileURLWithPath: "/Users/ctm/Archiv/§ O reswift.md"))
        textView.textContainerInset = NSSize(width: 0, height: scrollView.bounds.height / 2)
        textView.textStorage?.delegate = self

        scrollView.contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(self, selector: #selector(scrollViewDidScroll(_:)), name: .NSViewBoundsDidChange, object: scrollView.contentView)
    }

    func scrollViewDidScroll(_ notification: Notification) {
        print(self.scrollView.contentView.bounds)
        return
    }

    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {

        guard let layoutManager = textView.layoutManager else { return }

        print(">")

        let insertionPointGlyphIndex: Int = {
            // Jump to the character after the newline, not the newline itself
            if editedRange.length == 1,
                (textStorage.string as NSString).substring(with: editedRange).hasSuffix("\n") {
                return min(
                    editedRange.location + 1,
                    layoutManager.numberOfGlyphs)
            }

            // The old known location in both the store and layout manager
            return editedRange.location
        }()

        // Layout manager did not process the changes, so the glyph index may not be right
        let lineRect = layoutManager.lineFragmentRect(forGlyphAt: insertionPointGlyphIndex, effectiveRange: nil)

        highlighter.frame = highlighter.superview!
            .convert(lineRect, from: textView)
            .offsetBy(dx: 0, dy: textView.textContainerInset.height)
        textView.scroll(lineRect.origin)//.applying(.init(translationX: 0, y: lineRect.size.height)))
    }
}

class TypewriterTextView: NSTextView {
    override func scrollToVisible(_ rect: NSRect) -> Bool {
//        self.enclosingScrollView?.contentView.scroll(to: rect.origin)
        return false//super.scrollToVisible(rect)
    }
}


class HighlightView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSColor(calibratedRed: 1, green: 1, blue: 0, alpha: 0.3).set()
        NSRectFill(dirtyRect)
    }
}
