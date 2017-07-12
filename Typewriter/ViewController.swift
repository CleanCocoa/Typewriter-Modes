//
//  ViewController.swift
//  Typewriter
//
//  Created by Christian Tietze on 03.07.17.
//  Copyright © 2017 Christian Tietze. All rights reserved.
//

import Cocoa

var scrollViewContext: Void?

enum TypewriterModeSetting {

    case fixed
    case overscrollFlexible
    case bottomOverscrollFlexible
    case finalFantasy

    var typewriterMode: TypewriterMode {
        switch self {
        case .fixed: return FixedTypewriterMode()
        case .overscrollFlexible: return FullOverscrollFlexibleTypewriterMode(heightProportion: 1)
        case .bottomOverscrollFlexible: return BottomOverscrollFlexibleTypewriterMode()
        case .finalFantasy: return FinalFantasyTypewriterMode()
        }
    }

    init?(fromTag tag: Int) {
        switch tag {
        case 1: self = .fixed
        case 2: self = .overscrollFlexible
        case 3: self = .bottomOverscrollFlexible
        case 4: self = .finalFantasy
        default: return nil
        }
    }
}

class ViewController: NSViewController, NSTextStorageDelegate, TypewriterTextStorageDelegate, NSTextViewDelegate {

    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet var textView: TypewriterTextView!

    var typewriterModeSetting: TypewriterModeSetting? {
        didSet {
            textView.typewriterMode = typewriterModeSetting?.typewriterMode

            if isInTypewriterMode {
                textView.lockTypewriterDistance()
                alignScrollingToInsertionPoint()
            } else {
                textView.unlockTypewriterDistance()
                textView.hideHighlight()
            }

            textView.needsDisplay = true
        }
    }
    var isInTypewriterMode: Bool { return typewriterModeSetting != nil }

    @IBAction func changeTypewriterMode(_ sender: Any?) {
        guard let menuItem = sender as? NSMenuItem else { return }
        self.typewriterModeSetting = TypewriterModeSetting(fromTag: menuItem.tag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let textStorage = TypewriterTextStorage()
        textStorage.typewriterDelegate = self
        textStorage.delegate = self
        textView.layoutManager?.replaceTextStorage(textStorage)

        // Without a custom layout manager, some errors do not surface, so it's
        // a good idea to keep this useless replacement during development.
        textView.textContainer?.replaceLayoutManager(NSLayoutManager())

        textView.string = (try? String(contentsOf: URL(fileURLWithPath: "/Users/ctm/Archiv/§ O reswift.md"))) ?? ""

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
        textView.relayoutTypewriterMode(scrollView: scrollView)
    }

    // MARK: - Typewriter Scrolling

    private var needsTypewriterDistanceReset = false

    /// Indicates if the text storage is currently processing changes
    /// and current text view changes reflect programmatic adjustments.
    private var isProcessingEdit = false
    private var isUserInitiated: Bool { return !isProcessingEdit }

    func textViewDidChangeSelection(_ notification: Notification) {
        guard isInTypewriterMode else { return }
        guard isUserInitiated else { return }
        needsTypewriterDistanceReset = true
    }

    
    // MARK: Preparation

    func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {

        guard isInTypewriterMode else { return }
        isProcessingEdit = true
    }

    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {

        guard isInTypewriterMode else { return }
        scheduleScrollingToInsertionPoint()
    }

    fileprivate var shouldScrollToInsertionPoint = false
    fileprivate func scheduleScrollingToInsertionPoint() {

        shouldScrollToInsertionPoint = true
    }


    // MARK: Execution

    func typewriterTextStorageDidEndEditing(_ typewriterTextStorage: TypewriterTextStorage) {

        processScrollingToInsertionPoint()
    }

    fileprivate func processScrollingToInsertionPoint() {

        guard shouldScrollToInsertionPoint else { return }
        defer { shouldScrollToInsertionPoint = false }

        alignScrollingToInsertionPoint()
        isProcessingEdit = false
    }

    fileprivate func alignScrollingToInsertionPoint() {

        guard let layoutManager = textView.layoutManager else { return }

        if needsTypewriterDistanceReset {
            textView.lockTypewriterDistance()
            needsTypewriterDistanceReset = false
        }

        let lineRect = insertionPointLineRect(
            textView: textView,
            layoutManager: layoutManager)
        textView.moveHighlight(rectInTextView: lineRect)
        textView.typewriterScroll(to: lineRect.origin)
    }
}

func insertionPointLineRect(textView: NSTextView, layoutManager: NSLayoutManager) -> NSRect {

    let location = textView.selectedRange().location

    if location >= layoutManager.numberOfGlyphs {
        let extraLineFragmentRect = layoutManager.extraLineFragmentRect
        if extraLineFragmentRect != NSRect.zero,
            // When typing at the very end, sometimes the origin
            // is -(lineHeight) for no apparent reason.
            extraLineFragmentRect.origin.y >= 0 {
            return layoutManager.extraLineFragmentRect
        }
    }

    let insertionPointGlyphIndex = min(location, layoutManager.numberOfGlyphs - 1)

    return layoutManager.lineFragmentRect(forGlyphAt: insertionPointGlyphIndex, effectiveRange: nil)
}
