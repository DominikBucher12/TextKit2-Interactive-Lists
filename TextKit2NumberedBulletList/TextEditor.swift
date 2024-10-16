//
//  DDTextView.swift
//  TextKit2NumberedBulletList
//
//  Created by Dominik Bucher on 05.03.2024.
//

import Foundation
import UIKit
import SwiftUI

public class TextEditorModel: NSObject, ObservableObject {
    
    @Published var isParagraphActive: Bool = false
    @Published var isNestedParagraph: Bool = false
    
    weak var textView: CustomTextView?
    func setNumberedParagraph() {
        let list = NSTextList(markerFormat: .decimal, options: 0)
        
        let listParagraph = NSMutableParagraphStyle()
        listParagraph.paragraphSpacing = 0
        listParagraph.lineSpacing = 15
        listParagraph.textLists = [list]
        listParagraph.alignment = .left
        
        
        textView!.typingAttributes[.paragraphStyle] = listParagraph
        
        textView!.setAttributes([.paragraphStyle: listParagraph], forRange: textView!.selectedRange)
    }
    
    func nestParagraph() {
        let nestedList = NSTextList(markerFormat: .square, options: 0)
        (textView?.typingAttributes[.paragraphStyle] as? NSMutableParagraphStyle)?.textLists.append(nestedList)
    }
    
    func unnestParagraph() {
        let paragraph = textView?.typingAttributes[.paragraphStyle] as? NSMutableParagraphStyle
        paragraph?.textLists.removeAll { !$0.isOrdered }
    }
    
    func unsetNumberedParagraph() {
        textView?.typingAttributes[.paragraphStyle] = nil
        textView?.removeAttributes(in: textView!.selectedRange, forAttribute: .paragraphStyle)
    }
}

public struct CustomTextEditor: UIViewRepresentable {
    @ObservedObject private var model: TextEditorModel
    
    private var text: Binding<NSAttributedString>
    private var textView = CustomTextView()
    
    public init(text: Binding<NSAttributedString>, model: TextEditorModel) {
        self.text = text
        self.textView.delegate = model
        self._model = ObservedObject(initialValue: model)
    }

    public func makeUIView(context: Context) -> some UIView {
        model.textView = textView
        return textView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {}
}
