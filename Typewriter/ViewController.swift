//
//  ViewController.swift
//  Typewriter
//
//  Created by Christian Tietze on 03.07.17.
//  Copyright © 2017 Christian Tietze. All rights reserved.
//

import Cocoa

var scrollViewContext: Void?

class ViewController: NSViewController, NSTextStorageDelegate, TypewriterTextStorageDelegate, TypewriterLayoutManagerDelegate, NSTextViewDelegate {

    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet var textView: TypewriterTextView!

    var isInTypewriterMode = false {
        didSet {
            if isInTypewriterMode {
                textView.lockTypewriterDistance()
                alignScrollingToInsertionPoint()
                textView.needsDisplay = true
            } else {
                textView.unlockTypewriterDistance()
                textView.hideHighlight()
                textView.needsDisplay = true
            }
        }
    }

    @IBAction func toggleTypewriterMode(_ sender: Any?) {
        isInTypewriterMode = !isInTypewriterMode
    }

    private var isProcessingEdit = false

    func layoutManagerWillProcessEditing(_ layoutManager: TypewriterLayoutManager) {
        isProcessingEdit = true
    }

    func layoutManagerDidProcessEditing(_ layoutManager: TypewriterLayoutManager) {
        isProcessingEdit = false
    }

    private var needsTypewriterDistanceReset = false

    func textViewDidChangeSelection(_ notification: Notification) {

        guard isInTypewriterMode else { return }
        guard let textView = notification.object as? TypewriterTextView else { return }
        guard !isProcessingEdit else { return }

        needsTypewriterDistanceReset = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let layoutManager = TypewriterLayoutManager()
        layoutManager.typewriterDelegate = self
        let textStorage = TypewriterTextStorage()
        textStorage.typewriterDelegate = self
        textStorage.delegate = self
        textView.layoutManager?.replaceTextStorage(textStorage)
        textView.textContainer?.replaceLayoutManager(layoutManager)

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

    func textStorageDidEndEditing(_ typewriterTextStorage: TypewriterTextStorage, butItReallyOnlyProcessedTheEdit endingAfterProcessing: Bool) {

        // If we would not schedule for later here, the layout manager would not be in
        // a valid state for querying. So we wait for it. Needed for deletion only, it seems.
        guard !endingAfterProcessing else { RunLoop.current.perform(processScrollPreparation); return }
        processScrollPreparation()

    }

    fileprivate func processScrollPreparation() {

        guard let preparation = self.pendingPreparation else { return }
        self.pendingPreparation = nil
        if needsTypewriterDistanceReset {
            textView.lockTypewriterDistance()
            needsTypewriterDistanceReset = false
        }
        preparation.scrollCommand().performScroll()
    }
}

protocol TypewriterLayoutManagerDelegate: class {
    func layoutManagerWillProcessEditing(_ layoutManager: TypewriterLayoutManager)
    func layoutManagerDidProcessEditing(_ layoutManager: TypewriterLayoutManager)
}

class TypewriterLayoutManager: NSLayoutManager {

    weak var typewriterDelegate: TypewriterLayoutManagerDelegate?

    override func processEditing(for textStorage: NSTextStorage, edited editMask: NSTextStorageEditActions, range newCharRange: NSRange, changeInLength delta: Int, invalidatedRange invalidatedCharRange: NSRange) {

        typewriterDelegate?.layoutManagerWillProcessEditing(self)
        super.processEditing(for: textStorage, edited: editMask, range: newCharRange, changeInLength: delta, invalidatedRange: invalidatedCharRange)
        typewriterDelegate?.layoutManagerDidProcessEditing(self)
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
