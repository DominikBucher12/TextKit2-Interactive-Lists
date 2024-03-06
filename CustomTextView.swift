//
//  CustomTextView.swift
//  TextKit2NumberedBulletList
//
//  Created by Dominik Bucher on 05.03.2024.
//

import Foundation
import UIKit

public final class CustomTextView: UITextView {
    var model: TextEditorModel?
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        // Explicitly initialize TextKit2.
        let textLayoutManager = NSTextLayoutManager()
        let textkit2Container = NSTextContainer()
        textLayoutManager.textContainer = textkit2Container
        let textContentStorage = NSTextContentStorage()
        textContentStorage.addTextLayoutManager(textLayoutManager)
        
        super.init(frame: frame, textContainer: textkit2Container)
        delegate = model
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

extension TextEditorModel: UITextViewDelegate {
    public func textViewDidChangeSelection(_ textView: UITextView) {
        // Get the selected range
        let selectedRange = textView.selectedRange
        
        // Check if there's any text selected
        guard selectedRange.length > 0 else {
            active = (textView.typingAttributes[.paragraphStyle] as? NSParagraphStyle)?.textLists.isNotEmpty ?? false
            return
        }
        
        // Get the attributes of the selected text
        let attributedText = textView.attributedText
        let attributes = attributedText?.attributes(at: selectedRange.location, effectiveRange: nil)
        
        // Check if the attributes contain a paragraph style
        active = (attributes?[.paragraphStyle] as? NSParagraphStyle)?.textLists.isNotEmpty ?? false
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let paragraph = textView.typingAttributes[.paragraphStyle] as? NSParagraphStyle
        let isInsideNumberedParagraph = !(paragraph?.textLists.isEmpty ?? true)
        
        // Case 1: Inserting new line after a numbered/bullet point
        if text == "\n" && isInsideNumberedParagraph {
            let text = textView.text as NSString
            let nextCharRange = NSRange(location: range.location, length: 1)
            // Check if the range is within the bounds of the text
            if nextCharRange.location < text.length {
                let nextChar = text.substring(with: nextCharRange)
                if nextChar != "\n" && nextChar != " " {
                    // Insert a new line after the second point
                    textView.insertText("\n")
                    // Set the cursor position just after the inserted text
                    textView.selectedRange = NSRange(location: range.location + 1, length: 0)
                    return true
                }
            } else {
                ensureTrailingNewline(for: textView)
                textView.selectedRange = range
                return true
            }
        }
        
        // Case 2: Opting out of using list
        if text == "\n" && textView.text.hasSuffix("\n\n") && isInsideNumberedParagraph {
            let text = textView.text as NSString
            let rangeToCheck = NSRange(location: range.location, length: 1)
            // Check if the range is within the bounds of the text
            if rangeToCheck.location < text.length {
                let nextChar = text.substring(with: rangeToCheck)
                if nextChar == "\n" {
                    let rangeToDelete = NSRange(location: range.location - 1, length: 1)
                    textView.textStorage.replaceCharacters(in: rangeToDelete, with: "")
                    textView.typingAttributes[.paragraphStyle] = nil
                    return true
                }
            }
        }
        
        // Case 3: Deleting character and going back to previous line
        if text == "" {
            let text = textView.text as NSString
            let prevCharRange = NSRange(location: range.location - 1, length: 1)
            // Check if the range is within the bounds of the text
            if prevCharRange.location >= 0 && prevCharRange.location < text.length {
                let prevChar = text.substring(with: prevCharRange)
                if prevChar == "\n" {
                    let rangeToDelete = NSRange(location: range.location, length: 1)
                    textView.textStorage.replaceCharacters(in: rangeToDelete, with: "")
                    textView.selectedRange = NSRange(location: range.location - 1, length: 0)
                    return true
                }
            }
        }
        return true
    }
    
    // Add trailing newLine :)
    private func ensureTrailingNewline(for textView: UITextView) {
        // Check if the last character is a newline
        if !textView.text.hasSuffix("\n") {
            textView.insertText("\n")
        }
    }
}


private extension Array {
    var isNotEmpty: Bool { !isEmpty }
}
