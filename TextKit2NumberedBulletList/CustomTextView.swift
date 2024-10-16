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

extension TextEditorModel: UITextViewDelegate {
    public func textViewDidChangeSelection(_ textView: UITextView) {
        let selectedRange = textView.selectedRange
        
        // Check if there's any text selected
        guard selectedRange.length > 0 else {
            isParagraphActive = (textView.typingAttributes[.paragraphStyle] as? NSParagraphStyle)?.textLists.isNotEmpty ?? false
            isNestedParagraph = (textView.typingAttributes[.paragraphStyle] as? NSParagraphStyle)?.textLists.last?.isOrdered == false
            return
        }
        
        // Get the attributes of the selected text
        let attributedText = textView.attributedText
        let attributes = attributedText?.attributes(at: selectedRange.location, effectiveRange: nil)
        
        // Check if the attributes contain a paragraph style
        isParagraphActive = (attributes?[.paragraphStyle] as? NSParagraphStyle)?.textLists.isNotEmpty ?? false
        isNestedParagraph = ((attributes?[.paragraphStyle] as? NSParagraphStyle)?.textLists.last?.isOrdered == false)
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Define if I am inside paragraph
        let paragraph = textView.typingAttributes[.paragraphStyle] as? NSParagraphStyle
        let isInsideNumberedParagraph = !(paragraph?.textLists.isEmpty ?? true)
        
        guard isInsideNumberedParagraph else { return true }
        
        if text == "\n" && textView.lastTwoCharactersBeforeSelectedRange()?.last == "\n" {
            let text = textView.text as NSString
            let rangeToCheck = NSRange(location: range.location, length: 1)
            // Check if the range is within the bounds of the text
            if rangeToCheck.location < text.length {
                let nextChar = text.substring(with: rangeToCheck)
                if nextChar == "\n" {
                    textView.removeAttributes(in: rangeToCheck, forAttribute: .paragraphStyle)
                    textView.textStorage.removeAttribute(.paragraphStyle, range: rangeToCheck)
                    textView.textStorage.insert(.init(string: "", attributes: [.foregroundColor: UIColor.red]), at: range.location)
                    
                    if let ensuringRange = textView.textLayoutManager?.documentRange {
                        textView.textLayoutManager?.ensureLayout(for: ensuringRange)
                    }
                    textView.selectedRange = .init(location: range.location, length: 0)
                    textView.typingAttributes[.paragraphStyle] = nil
                    return true
                }
            }
        }
        
        guard textView.isTextAfterSelectedRangeEmpty() else { return true }
        
        // Case 1: Inserting new line after a numbered/bullet point in order to always render the bullet/number immediately
        // after new line.
        if text == "\n" {
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
                
        // Case 3: Deleting character and going back to previous line
        if text == "" {
            let text = textView.text as NSString
            let prevCharRange = NSRange(location: range.location - 1, length: 1)
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
