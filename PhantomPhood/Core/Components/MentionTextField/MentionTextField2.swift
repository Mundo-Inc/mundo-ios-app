//
//  MentionTextField.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 5/28/24.
//

import SwiftUI

struct MentionTextField2: View {
    @StateObject private var vm: MentionTextFieldVM2
    @Binding private var text: String
    let placeholder: String?
    let size: CGFloat
    let trailingPadding: CGFloat
    
    init(text: Binding<String>, size: CGFloat, placeholder: String? = nil, trailingPadding: CGFloat = 0) {
        self._vm = StateObject(wrappedValue: MentionTextFieldVM2(text: text))
        self._text = text
        self.size = size
        self.placeholder = placeholder
        self.trailingPadding = trailingPadding
    }
    
    var body: some View {
        MentionTextFieldRepresentable(vm: vm, text: $text, placeholder: placeholder)
            .padding(.trailing, trailingPadding)
            .background(Color.themePrimary, in: .rect(cornerRadius: 10))
            .frame(height: size)
    }
}

fileprivate struct MentionTextFieldRepresentable: UIViewRepresentable {
    @ObservedObject var vm: MentionTextFieldVM2
    @Binding var text: String
    let placeholder: String?
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 18)
        
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        textView.invalidateIntrinsicContentSize()
        
//        let fixedWidth = textView.frame.size.width
//        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: 100))
//        textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> MentionTextFieldCoordinator {
        MentionTextFieldCoordinator(self, viewModel: vm, text: $text, placeholder: placeholder)
    }
    
    final class MentionTextFieldCoordinator: NSObject, UITextViewDelegate {
        var parent: MentionTextFieldRepresentable
        private var viewModel: MentionTextFieldVM2
        @Binding private var text:String
        let placeholder: String?
        
        init(_ parent: MentionTextFieldRepresentable, viewModel: MentionTextFieldVM2, text: Binding<String>, placeholder: String?) {
            self.parent = parent
            self.viewModel = viewModel
            self._text = text
            self.placeholder = placeholder
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            text = textView.text ?? ""
            
            if let selectedTextRange = textView.selectedTextRange {
                let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedTextRange.start)
                viewModel.handleMentionDetection(in: textView, at: cursorPosition)
            }
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text.isEmpty || textView.text == placeholder {
                textView.text = ""
                textView.textColor = UIColor(Color.primary)
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = placeholder ?? ""
                textView.textColor = UIColor(Color.secondary)
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            print("Here")
            if textView.contentSize.height >= 100 {
                textView.frame.size.height = 100
                textView.isScrollEnabled = true
            } else {
                textView.frame.size.height = textView.contentSize.height
                textView.isScrollEnabled = false // textView.isScrollEnabled = false for swift 4.0
            }
        }
        
//        func textFieldDidEndEditing(_ textField: UITextField) {
//            print("Hey")
//        }
    }
}

#Preview {
    @State var text = ""
    @State var showSuggestions = true
    
    return MentionTextField2(text: $text, size: 40)
}
