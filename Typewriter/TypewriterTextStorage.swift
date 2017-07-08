//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

class CustomTextStorageBase: NSTextStorage {

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

fileprivate extension String {
    var nsLength: Int {
        return (self as NSString).length
    }
}

protocol TypewriterTextStorageDelegate: class {
    func textStorageDidEndEditing(_ typewriterTextStorage: TypewriterTextStorage, butItReallyOnlyProcessedTheEdit endingAfterProcessing: Bool)
}

class TypewriterTextStorage: CustomTextStorageBase {

    weak var typewriterDelegate: TypewriterTextStorageDelegate?
    var isEditing: ((Bool) -> Void)?

    private var isBlockEditing = false
    private var wasBlockEditing = false

    override func beginEditing() {
        isBlockEditing = true
        super.beginEditing()
    }

    override func processEditing() {
        isEditing!(true)
        super.processEditing()

        if !wasBlockEditing { typewriterDelegate?.textStorageDidEndEditing(self, butItReallyOnlyProcessedTheEdit: true) }
        wasBlockEditing = false
        isEditing!(false)
    }

    override func endEditing() {
        // `super.endEditing()` triggers `processEditing`, so `wasBlockEditing` needs to be set first
        wasBlockEditing = isBlockEditing
        isBlockEditing = false
        super.endEditing()
        typewriterDelegate?.textStorageDidEndEditing(self, butItReallyOnlyProcessedTheEdit: false)
    }
}
