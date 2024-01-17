//
//  ReportView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/27/23.
//

import SwiftUI

enum ReportType: String {
    case review = "Review"
    case comment = "Comment"
}

enum FlagType: String, CaseIterable {
    case INAPPROPRIATE_CONTENT = "INAPPROPRIATE_CONTENT"
    case SPAM = "SPAM"
    case FALSE_INFORMATION = "FALSE_INFORMATION"
    case PERSONAL_INFORMATION = "PERSONAL_INFORMATION"
    case OFF_TOPIC = "OFF_TOPIC"
    case HARASSMENT = "HARASSMENT"
    case SUSPECTED_FAKE_REVIEW = "SUSPECTED_FAKE_REVIEW"
    case COPYRIGHT_VIOLATION = "COPYRIGHT_VIOLATION"
    case OTHER = "OTHER"
}

struct ReportView: View {
    let toastViewModel = ToastVM.shared
    let apiManager = APIManager.shared
    @ObservedObject var auth = Authentication.shared
    
    @Binding var id: String?
    let type: ReportType
    
    @State var flagType: FlagType? = nil
    @State var note = ""
    
    @State var step = 0
    
    func submit() async {
        do {
            guard let id, let flagType, let token = await auth.getToken() else { return }
            
            struct RequestBody: Encodable {
                let flagType: String
                let note: String
            }
            
            let body = try apiManager.createRequestBody(RequestBody(flagType: flagType.rawValue, note: note))
            try await apiManager.requestNoContent("/\(type == .review ? "reviews" : "comments")/\(id)/flag", method: .post, body: body, token: token)
            
            toastViewModel.toast(.init(type: .success, title: "Success", message: "We got your report. It can take up to 24 hours to respond."))
            
            self.id = nil
            self.flagType = nil
            self.note = ""
        } catch {
            toastViewModel.toast(.init(type: .error, title: "Something went wrong!", message: "Unable to submit your report"))
            print(error)
        }
    }
    
    var body: some View {
        ZStack {
            Color.black
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("Report \(type.rawValue)")
                        .font(.custom(style: .headline))
                    
                    Spacer()
                    
                    Button {
                        id = nil
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                if step == 0 {
                    ScrollView {
                        ForEach(FlagType.allCases, id: \.self) { flag in
                            Button {
                                withAnimation {
                                    flagType = flag
                                }
                            } label: {
                                Text(flag.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(flagType == flag ? Color.accentColor : Color.themePrimary)
                                    .clipShape(.rect(cornerRadius: 5))
                            }
                            .font(.custom(style: .body))
                            .foregroundStyle(flagType == flag ? Color.white : Color.primary)
                        }
                    }
                } else if step == 1 {
                    TextField("Any notes on this (Optional)", text: $note, axis: .vertical)
                        .lineLimit(4...6)
                        .overlay {
                            if note.count > 0 {
                                Text("\(note.count)/250")
                                    .foregroundStyle(note.count > 250 ? .red : Color.secondary)
                                    .padding(.bottom, 8)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            }
                        }
                    
                    Spacer()
                }
                
                HStack {
                    Button {
                        id = nil
                    } label: {
                        Text("Cancel")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    
                    Spacer()
                    
                    Button {
                        if step == 0 {
                            withAnimation {
                                step += 1
                            }
                        } else if step == 1 {
                            Task {
                                await submit()
                            }
                        }
                    } label: {
                        Text(step == 0 ? "Next" : "Submit")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .font(.custom(style: .body))
                .padding(.bottom)
            }
            .padding(.horizontal)
        }
        .transition(.move(edge: .bottom))
    }
}

#Preview {
    ReportView(id: .constant("Test"), type: .review)
}
