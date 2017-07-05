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
    func textStorageDidEndEditing(_ typewriterTextStorage: TypewriterTextStorage)
}

class TypewriterTextStorage: CustomTextStorageBase {

    weak var typewriterDelegate: TypewriterTextStorageDelegate?

    override func endEditing() {
        super.endEditing()
        typewriterDelegate?.textStorageDidEndEditing(self)
    }
}
