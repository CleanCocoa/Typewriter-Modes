//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

class CustomTextStorageBase: NSTextStorage {

    internal let content = NSMutableAttributedString()

    public override var string: String { return content.string }

    public override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [String : Any] {
        return content.attributes(at: location, effectiveRange: range)
    }

    public override func replaceCharacters(in range: NSRange, with str: String) {
        beginEditing()
        content.replaceCharacters(in: range, with: str)
        self.edited(.editedCharacters, range: range, changeInLength: str.nsLength - range.length)
        endEditing()
    }

    public override func setAttributes(_ attrs: [String : Any]?, range: NSRange) {
        beginEditing()
        content.setAttributes(attrs, range: range)
        self.edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
}

fileprivate extension String {
    var nsLength: Int {
        return (self as NSString).length
    }
}

protocol TypewriterTextStorageDelegate: class {
    /// Like `textStorage(_:willProcessEditing:range:changeInLength:)` called
    /// before the actual processing begins.
    func typewriterTextStorageWillProcessEditing(_ typewriterTextStorage: TypewriterTextStorage)

    /// Called after `typewriterTextStorageDidEndEditing`, if `processEditing()`
    /// does emit that message.
    func typewriterTextStorageDidProcessEditing(_ typewriterTextStorage: TypewriterTextStorage)

    /// Called to notify about the end of `endEditing()`, or in case of an edit
    /// outside of a begin/end editing block, at the end of `processEditing()`
    /// but before `typewriterTextStorageDidProcessEditing(_:)`.
    func typewriterTextStorageDidEndEditing(
        _ typewriterTextStorage: TypewriterTextStorage,
        butItReallyOnlyProcessedTheEdit endingAfterProcessing: Bool)
}

class TypewriterTextStorage: CustomTextStorageBase {

    weak var typewriterDelegate: TypewriterTextStorageDelegate?

    private var isBlockEditing = false
    private var wasBlockEditing = false

    override func beginEditing() {
        isBlockEditing = true
        super.beginEditing()
    }

    override func processEditing() {
        typewriterDelegate?.typewriterTextStorageWillProcessEditing(self)

        super.processEditing()

        if !wasBlockEditing { typewriterDelegate?.typewriterTextStorageDidEndEditing(self, butItReallyOnlyProcessedTheEdit: true) }
        wasBlockEditing = false

        typewriterDelegate?.typewriterTextStorageDidProcessEditing(self)
    }

    override func endEditing() {
        // `super.endEditing()` triggers `processEditing`, so `wasBlockEditing` needs to be set first
        wasBlockEditing = isBlockEditing
        isBlockEditing = false
        super.endEditing()
        typewriterDelegate?.typewriterTextStorageDidEndEditing(self, butItReallyOnlyProcessedTheEdit: false)
    }
}
