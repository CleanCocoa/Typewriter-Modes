//
//  ViewController.swift
//  Typewriter
//
//  Created by Christian Tietze on 03.07.17.
//  Copyright © 2017 Christian Tietze. All rights reserved.
//

import Cocoa

var scrollViewContext: Void?

class ViewController: NSViewController, NSTextStorageDelegate, TypewriterTextStorageDelegate {

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

    @IBAction func toggleTypewriterMode(_ sender: Any?) {
        isInTypewriterMode = !isInTypewriterMode
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let textStorage = TypewriterTextStorage()
        textStorage.typewriterDelegate = self
        textStorage.delegate = self
        textView.layoutManager?.replaceTextStorage(textStorage)

        textView.string = try! String(contentsOf: URL(fileURLWithPath: "/Users/ctm/Archiv/§ O reswift.md"))

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
        textView.scrollViewDidResize(scrollView)
    }

    // MARK: - Typewriter Scrolling
    // MARK: Preparation

    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {

        guard isInTypewriterMode else { return }
        prepareScrollingToInsertionPoint()
    }

    fileprivate func alignScrollingToInsertionPoint() {

        prepareScrollingToInsertionPoint()
        processScrollPreparation()
    }

    fileprivate func prepareScrollingToInsertionPoint() {

        guard let layoutManager = textView.layoutManager else { return }

        prepareAlignScrolling(
            textView: textView,
            layoutManager: layoutManager)
    }

    fileprivate func prepareAlignScrolling(
        textView: TypewriterTextView,
        layoutManager: NSLayoutManager) {

        guard isInTypewriterMode else { return }

        let preparation = TypewriterScrollPreparation(
            textView: textView,
            layoutManager: layoutManager)

        prepareScroll(preparation)
    }

    // MARK: Execution

    private(set) var pendingPreparation: TypewriterScrollPreparation?

    func prepareScroll(_ preparation: TypewriterScrollPreparation) {
        self.pendingPreparation = preparation
    }

    func textStorageDidEndEditing(_ typewriterTextStorage: TypewriterTextStorage) {

        processScrollPreparation()
    }

    fileprivate func processScrollPreparation() {

        guard let preparation = self.pendingPreparation else { return }
        self.pendingPreparation = nil

        preparation.scrollCommand().performScroll()
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
