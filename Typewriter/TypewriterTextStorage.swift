//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

class CustomTextStorageBase: NSTextStorage {

    internal let content = NSTextStorage()

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
    /// Called to notify about the end of `endEditing()`.
    func typewriterTextStorageDidEndEditing(_ typewriterTextStorage: TypewriterTextStorage)
}

class TypewriterTextStorage: CustomTextStorageBase {

    weak var typewriterDelegate: TypewriterTextStorageDelegate?

    override func beginEditing() {
        super.beginEditing()
    }

    override func processEditing() {
        super.processEditing()
    }

    override func endEditing() {
        super.endEditing()
        typewriterDelegate?.typewriterTextStorageDidEndEditing(self)
    }
}
