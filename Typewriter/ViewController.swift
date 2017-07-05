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

    var isInTypewriterMode = false {
        didSet {
            if isInTypewriterMode {
                alignScrollingToInsertionPoint()
                textView.needsDisplay = true
            } else {
                textView.hideHighlight()
                textView.needsDisplay = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textView.string = try! String(contentsOf: URL(fileURLWithPath: "/Users/ctm/Archiv/§ O reswift.md"))
        textView.textContainerInset = NSSize(width: 0, height: scrollView.frame.height / 2)
        textView.textStorage?.delegate = self

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

    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {

        guard isInTypewriterMode else { return }
        guard let layoutManager = textView.layoutManager else { return }

        alignScrolling(editedRange: editedRange, changeInLength: delta, textStorage: textStorage, layoutManager: layoutManager)
    }

    fileprivate func alignScrollingToInsertionPoint() {

        guard let textStorage = textView.textStorage else { return }
        guard let layoutManager = textView.layoutManager else { return }

        alignScrolling(
            editedRange: textView.selectedRange(),
            textStorage: textStorage,
            layoutManager: layoutManager)
    }

    fileprivate func alignScrolling(
        editedRange: NSRange,
        changeInLength delta: Int = 0,
        textStorage: NSTextStorage,
        layoutManager: NSLayoutManager) {

        guard isInTypewriterMode else { return }

        let didTypeNewline: Bool =
            // affected range is a newline character
            editedRange.length == 1
                && (textStorage.string as NSString).substring(with: editedRange).hasSuffix("\n")
                // ... but not through deleting backwards to the end of a line
                && delta != -1

        let preparation = TypewriterScrollPreparation(
            textView: textView,
            textStorage: textStorage,
            editedRange: editedRange,
            didTypeNewline: didTypeNewline)

        let lineRect: NSRect = {

            let lineRect: NSRect = {
                if editedRange.location >= layoutManager.numberOfGlyphs,
                    layoutManager.extraLineFragmentRect != NSRect.zero {
                    return layoutManager.extraLineFragmentRect
                }

                let insertionPointGlyphIndex = min(editedRange.location, layoutManager.numberOfGlyphs - 1)

                return layoutManager.lineFragmentRect(forGlyphAt: insertionPointGlyphIndex, effectiveRange: nil)
            }()

            let offset: CGFloat = {
                if didTypeNewline {
                    // Jump to the line after the newline character which is not
                    // known to the layout manager, yet.
                    return lineRect.height
                }
                return 0
            }()

            return lineRect.offsetBy(dx: 0, dy: offset)
        }()

        preparation.scroll(lineRect: lineRect)
    }

    @IBAction func toggleTypewriterMode(_ sender: Any?) {
        isInTypewriterMode = !isInTypewriterMode
    }
}

class TypewriterTextView: NSTextView {

    var isDrawingTypingHighlight = true
    var highlight: NSRect = NSRect.zero

    override func drawBackground(in rect: NSRect) {
        super.drawBackground(in: rect)

        guard isDrawingTypingHighlight else { return }

        // TODO: highlight is not production-ready: resizing the container does not move the highlight and pasting strings spanning multiple line fragments, then typing a character shows 2 highlighters
        NSColor(calibratedRed: 1, green: 1, blue: 0, alpha: 1).set()
        NSRectFill(highlight)
    }

    func hideHighlight() {
        highlight = NSRect.zero
    }

    func moveHighlight(rect: NSRect) {
        highlight = rect
    }
}

struct TypewriterScroll {
    let textView: TypewriterTextView
    let lineRect: NSRect

    func performScroll() {

        textView.moveHighlight(rect: textView.superview!
            .convert(lineRect, from: textView)
            .offsetBy(dx: 0, dy: textView.textContainerInset.height))
        textView.scroll(lineRect.origin)
    }
}
struct TypewriterScrollPreparation {
    let textView: TypewriterTextView
    let textStorage: NSTextStorage
    let editedRange: NSRange
    let didTypeNewline: Bool

    func scroll(lineRect: NSRect) {
        TypewriterScroll(textView: textView, lineRect: lineRect)
            .performScroll()
    }
}
