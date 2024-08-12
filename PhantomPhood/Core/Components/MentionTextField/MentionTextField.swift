//
//  MentionTextField.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 5/28/24.
//

import SwiftUI

struct MentionTextField: View {
    @StateObject private var vm: MentionTextFieldVM
    @Binding private var text: String
    private let placeholder: String?
    private let size: CGFloat
    private let trailingPadding: CGFloat
    
    init(text: Binding<String>, size: CGFloat, placeholder: String? = nil, trailingPadding: CGFloat = 0) {
        self._vm = StateObject(wrappedValue: MentionTextFieldVM(text: text))
        self._text = text
        self.size = size
        self.placeholder = placeholder
        self.trailingPadding = trailingPadding
    }
    
    var body: some View {
        MentionTextFieldRepresentable(vm: vm, text: $text, placeholder: placeholder)
            .padding(.all, 10)
            .padding(.trailing, trailingPadding)
            .frame(height: size)
            .background(Color.themePrimary, in: .rect(cornerRadius: 10))
            .overlay(alignment: .bottom) {
                if vm.isShowingSuggestions {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(vm.suggestions) { user in
                                Button {
                                    withAnimation {
                                        vm.onSelect(user: user)
                                    }
                                } label: {
                                    HStack {
                                        ProfileImageBase(user.profileImage, size: 32)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Group {
                                                if user.verified {
                                                    HStack(spacing: 3) {
                                                        Text(user.name)
                                                            .cfont(.caption)
                                                        Image(systemName: "checkmark.seal")
                                                            .font(.system(size: 12))
                                                            .foregroundStyle(.blue)
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                } else {
                                                    Text(user.name)
                                                        .cfont(.caption)
                                                }
                                            }
                                            .cfont(.body)
                                            .fontWeight(.semibold)
                                            
                                            Text("@\(user.username)")
                                                .cfont(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                    .frame(height: 39)
                                    .background(Color.themePrimary)
                                }
                                .foregroundStyle(.primary)
                                
                                Divider()
                                    .frame(height: 1)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .frame(height: max(40, min(Double(vm.suggestions.count) * 40, 40 * 4)))
                    .background(Color.themePrimary)
                    .clipShape(.rect(cornerRadius: 10))
                    .offset(y: -(size + 4))
                }
            }
    }
}

fileprivate struct MentionTextFieldRepresentable: UIViewRepresentable {
    @ObservedObject var vm: MentionTextFieldVM
    @Binding var text: String
    let placeholder: String?
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.placeholder = placeholder

        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return textField
    }
    
    func updateUIView(_ textField: UITextField, context: Context) {
        textField.text = text
    }
    
    func makeCoordinator() -> MentionTextFieldCoordinator {
        MentionTextFieldCoordinator(viewModel: vm, text: $text)
    }
    
    final class MentionTextFieldCoordinator: NSObject, UITextFieldDelegate {
        private var viewModel: MentionTextFieldVM
        @Binding private var text:String
        
        init(viewModel: MentionTextFieldVM, text: Binding<String>) {
            self.viewModel = viewModel
            self._text = text
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.text = textField.text ?? ""
                
                if let selectedTextRange = textField.selectedTextRange {
                    let cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedTextRange.start)
                    self.viewModel.handleMentionDetection(in: textField, at: cursorPosition)
                }
            }
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
//        func textFieldDidEndEditing(_ textField: UITextField) {
//            print("Hey")
//        }
    }
}

#Preview {
    @State var text = ""
    @State var showSuggestions = true
    
    return MentionTextField(text: $text, size: 40)
}
