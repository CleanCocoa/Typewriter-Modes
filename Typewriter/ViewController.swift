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

        let textStorage = TypewriterTextStorage()
        textView.layoutManager?.replaceTextStorage(textStorage)

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
        guard let textStorage = textStorage as? TypewriterTextStorage else { return }
        guard let layoutManager = textView.layoutManager else { return }

        alignScrolling(editedRange: editedRange, changeInLength: delta, textStorage: textStorage, layoutManager: layoutManager)
    }

    fileprivate func alignScrollingToInsertionPoint() {

        guard let textStorage = textView.textStorage as? TypewriterTextStorage else { return }
        guard let layoutManager = textView.layoutManager else { return }

        alignScrolling(
            editedRange: textView.selectedRange(),
            textStorage: textStorage,
            layoutManager: layoutManager)
    }

    fileprivate func alignScrolling(
        editedRange: NSRange,
        changeInLength delta: Int = 0,
        textStorage: TypewriterTextStorage,
        layoutManager: NSLayoutManager) {

        guard isInTypewriterMode else { return }

        let preparation = TypewriterScrollPreparation(
            textView: textView,
            layoutManager: layoutManager)

        textStorage.prepareScroll(preparation)
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

struct TypewriterScrollCommand {

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

class CustomTextStorage: NSTextStorage {

    internal let content = NSMutableAttributedString()

    public override var string: String { return content.string }

    public override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [String : Any] {
        return content.attributes(at: location, effectiveRange: range)
    }

    public override func replaceCharacters(in range: NSRange, with str: String) {
        content.replaceCharacters(in: range, with: str)
        self.edited(.editedCharacters, range: range, changeInLength: str.nsLength - range.length)
    }

    public override func setAttributes(_ attrs: [String : Any]?, range: NSRange) {
        content.setAttributes(attrs, range: range)
        self.edited(.editedAttributes, range: range, changeInLength: 0)
    }
}

extension String {
    var nsLength: Int {
        return (self as NSString).length
    }
}

class TypewriterTextStorage: CustomTextStorage {

    private(set) var pendingPreparation: TypewriterScrollPreparation?

    func prepareScroll(_ preparation: TypewriterScrollPreparation) {
        self.pendingPreparation = preparation
    }

    override func endEditing() {
        super.endEditing()

        guard let preparation = self.pendingPreparation else { return }
        self.pendingPreparation = nil

        preparation.scrollCommand().performScroll()
    }
}
