//
//  UITextView+Extensions.swift
//  TextKit2NumberedBulletList
//
//  Created by Dominik Bucher on 06.03.2024.
//

import UIKit

extension UITextView {
    func hasTextAfterSelectedRange() -> Bool {
        guard let selectedRange = self.selectedTextRange else {
            return false
        }
        
        // Get the end of the selected range
        let endOfSelection = selectedRange.end
        
        // Get the start index of the text after the selected range
        guard let textAfterSelectionStartIndex = self.position(from: endOfSelection, offset: 0),
              let rangeAfterSelection = self.textRange(from: textAfterSelectionStartIndex, to: self.endOfDocument) else {
            return false
        }
        
        // Get the text after the selected range
        let textAfterSelection = self.text(in: rangeAfterSelection)
        
        // Check if there is any text after the selected range
        return textAfterSelection != nil && !textAfterSelection!.isEmpty
    }
    
    func isTextAfterSelectedRangeEmpty() -> Bool {
        return !hasTextAfterSelectedRange()
    }
}

extension UITextView {
    func setAttributes(_ attributes: [NSAttributedString.Key: Any], forRange range: NSRange) {
        textStorage.addAttributes(attributes, range: range)
    }
}

extension UITextView {
    func removeAttributes(in range: NSRange, forAttribute attribute: NSAttributedString.Key) {
        guard let attributedText = attributedText else { return }
        
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
        mutableAttributedText.removeAttribute(attribute, range: range)
        self.attributedText = mutableAttributedText
    }
}

extension UITextView {
    func lastTwoCharactersBeforeSelectedRange() -> String? {
        guard !text.isEmpty else { return nil }
    
        let selectedRange = self.selectedRange
        let startIndex = max(0, selectedRange.location - 2)
        let length = min(selectedRange.location, 2)
        
        // Extract the last two characters before the selected range
        let substringRange = NSRange(location: startIndex, length: length)
        
        guard
            let substringStartIndex = text.index(
                text.startIndex,
                offsetBy: substringRange.location,
                limitedBy: text.endIndex
            ),
            let substringEndIndex = text.index(
                substringStartIndex,
                offsetBy: substringRange.length,
                limitedBy: text.endIndex
            )
        else { return nil }
        
        let lastTwoCharacters = String(text[substringStartIndex..<substringEndIndex])
        
        return lastTwoCharacters
    }
}
