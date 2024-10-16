//
//  ContentView.swift
//  TextKit2NumberedBulletList
//
//  Created by Dominik Bucher on 05.03.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var model = TextEditorModel()
    @State private var text = NSAttributedString()
    @State var showList = false
    @State var nestItems = false
    var body: some View {
        VStack {
            CustomTextEditor(text: $text, model: model)
            HStack {
                Button("Ordered list: \(model.isParagraphActive.description)") {
                    showList.toggle()
                }
                .buttonStyle(.bordered)
                Button("Nested: \(model.isNestedParagraph.description)") {
                    nestItems.toggle()
                }
                .buttonStyle(.bordered)
            }
        }
        .onChange(of: showList) {
            if model.isParagraphActive {
                model.unsetNumberedParagraph()
            } else {
                model.setNumberedParagraph()
            }
        }
        .onChange(of: nestItems) {
            if model.isNestedParagraph {
                model.unnestParagraph()
            } else {
                model.nestParagraph()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
