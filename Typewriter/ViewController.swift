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

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.string = try! String(contentsOf: URL(fileURLWithPath: "/Users/ctm/Archiv/§ O reswift.md"))
        textView.textContainerInset = NSSize(width: 0, height: scrollView.bounds.height / 2)
        textView.textStorage?.delegate = self
    }

    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {

        guard let window = textView.window else { return }
        var ptr = NSRange.init()
        let visibleRect = textView.firstRect(forCharacterRange: editedRange, actualRange: &ptr)
        let editedRect = textView.convert(window.convertFromScreen(visibleRect), from: nil)

        let bottom = editedRect.origin
            .applying(.init(translationX: 0, y: scrollView.bounds.height / 2))
        textView.scroll(bottom)
    }
}

class TypewriterTextView: NSTextView { }
