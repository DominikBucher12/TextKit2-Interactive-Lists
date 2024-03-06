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
    var body: some View {
        VStack {
            CustomTextEditor(text: $text, model: model)
            Button("Ordered list: \(model.active.description)") {
                showList.toggle()
            }
            .buttonStyle(.bordered)
        }
        .onChange(of: showList) {
            if model.active {
                model.unsetNumberedParagraph()
            } else {
                model.setNumberedParagraph()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
