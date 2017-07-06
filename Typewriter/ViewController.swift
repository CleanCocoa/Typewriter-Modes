//
//  ViewController.swift
//  Typewriter
//
//  Created by Christian Tietze on 03.07.17.
//  Copyright © 2017 Christian Tietze. All rights reserved.
//

import Cocoa

var scrollViewContext: Void?

class ViewController: NSViewController, NSTextStorageDelegate, TypewriterTextStorageDelegate, NSTextViewDelegate {

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

    private var needsTypewriterDistanceReset = false

    func textViewDidChangeSelection(_ notification: Notification) {
        guard isInTypewriterMode else { return }
        needsTypewriterDistanceReset = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let textStorage = TypewriterTextStorage()
        textStorage.typewriterDelegate = self
        textStorage.delegate = self
        textView.layoutManager?.replaceTextStorage(textStorage)

        // Without a custom layout manager, some errors do not surface.
        let layoutManager = TypewriterLayoutManager()
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
        // a valid state for querying and the app crashes. So we schedule the command for later.
        // Affects deletion only, it seems, so the tradeoff (making it an async problem) isn't that bad.
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

class TypewriterLayoutManager: NSLayoutManager {}
