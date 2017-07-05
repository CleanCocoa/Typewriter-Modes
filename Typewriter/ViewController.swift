//
//  ViewController.swift
//  Typewriter
//
//  Created by Christian Tietze on 03.07.17.
//  Copyright © 2017 Christian Tietze. All rights reserved.
//

import Cocoa

var scrollViewContext: Void?

class ViewController: NSViewController, NSTextStorageDelegate {

    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet var textView: TypewriterTextView!

    var highlighter: HighlightView!

    override func viewDidLoad() {
        super.viewDidLoad()

        highlighter = HighlightView(frame: NSRect.zero)
        textView.superview!.addSubview(highlighter)

        textView.string = try! String(contentsOf: URL(fileURLWithPath: "/Users/ctm/Archiv/§ O reswift.md"))
        textView.textContainerInset = NSSize(width: 0, height: scrollView.frame.height / 2)
        textView.textStorage?.delegate = self

        scrollView.contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(self, selector: #selector(scrollViewDidScroll(_:)), name: .NSViewBoundsDidChange, object: scrollView.contentView)

        scrollView.addObserver(self, forKeyPath: "frame", options: [.new, .initial], context: &scrollViewContext)

    }


    deinit {
        scrollView.removeObserver(self, forKeyPath: "frame")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        guard
            context == &scrollViewContext,
            let scrollView = object as? NSScrollView
            else { return }

        scrollViewDidResize(scrollView)
    }

    func scrollViewDidResize(_ scrollView: NSScrollView) {
        textView.textContainerInset = NSSize(width: 0, height: scrollView.bounds.height / 2)
    }

    func scrollViewDidScroll(_ notification: Notification) {
        print(self.scrollView.contentView.bounds)
        return
    }

    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {

        guard let layoutManager = textView.layoutManager else { return }

        print(">")

        let lineRect: NSRect = {

            var insertionPointGlyphIndex = editedRange.location

            if insertionPointGlyphIndex >= layoutManager.numberOfGlyphs,
                layoutManager.extraLineFragmentRect != NSRect.zero {
                return layoutManager.extraLineFragmentRect
            }

            insertionPointGlyphIndex = min(insertionPointGlyphIndex, layoutManager.numberOfGlyphs - 1)

            let lineRect = layoutManager.lineFragmentRect(forGlyphAt: insertionPointGlyphIndex, effectiveRange: nil)

            let offset: CGFloat = {
                if editedRange.length == 1 && delta != -1,
                    (textStorage.string as NSString).substring(with: editedRange).hasSuffix("\n") {
                    // Jump to the line after the newline character
                    return lineRect.height
                }
                return 0
            }()

            return lineRect.offsetBy(dx: 0, dy: offset)
        }()

        highlighter.frame = highlighter.superview!
            .convert(lineRect, from: textView)
            .offsetBy(dx: 0, dy: textView.textContainerInset.height)
        textView.scroll(lineRect.origin)    }
}

class TypewriterTextView: NSTextView {
    override func scrollToVisible(_ rect: NSRect) -> Bool {
        return super.scrollToVisible(rect)
    }
}


class HighlightView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSColor(calibratedRed: 1, green: 1, blue: 0, alpha: 0.3).set()
        NSRectFill(dirtyRect)
    }
}
