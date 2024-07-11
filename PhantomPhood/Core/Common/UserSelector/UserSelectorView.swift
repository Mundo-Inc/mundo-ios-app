//
//  UserSelectorView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/2/24.
//

import SwiftUI

struct UserSelectorView: View {
    @StateObject private var vm = UserSelectorVM()
    
    private let onSelect: (UserEssentials) -> Void
    
    init(onSelect: @escaping (UserEssentials) -> Void = { _ in }) {
        self.onSelect = onSelect
    }
    
    @FocusState private var textFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            TextField(text: $vm.searchText) {
                Label("Search", systemImage: "magnifyingglass")
            }
            .withFilledStyle(size: .medium, paddingTrailing: 95)
            .textInputAutocapitalization(.never)
            .focused($textFocused)
            .padding()
            .onAppear {
                textFocused = true
            }
            
            Divider()
            
            Group {
                if vm.searchResults.isEmpty {
                    List(0...15, id: \.self) { _ in
                        UserCard.placeholder
                            .listRowBackground(Color.clear)
                    }
                } else {
                    List(vm.searchResults) { user in
                        UserCard(user: user, onSelect: onSelect)
                            .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(.plain)
            .scrollDismissesKeyboard(.interactively)
            .opacity(vm.isLoading ? 0.6 : 1)
        }
        .presentationDetents([.fraction(0.99)])
    }
}

fileprivate struct UserCard: View {
    @Environment(\.dismiss) private var dismiss

    let user: UserEssentials
    let onSelect: (UserEssentials) -> Void
    
    var body: some View {
        Button {
            self.onSelect(user)
            dismiss()
        } label: {
            HStack {
                ProfileImage(user.profileImage, size: 42, cornerRadius: 10)
                
                VStack {
                    if (user.verified) {
                        HStack {
                            Text(user.name)
                                .cfont(.body)
                                .bold()
                            Image(systemName: "checkmark.seal")
                                .font(.system(size: 12))
                                .foregroundStyle(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    } else {
                        Text(user.name)
                            .cfont(.body)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Text("@" + user.username)
                        .cfont(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.secondary)
                    
                }
                
                LevelView(level: user.progress.level)
                    .frame(width: 25, height: 25)
            }
        }
        .foregroundStyle(.primary)
    }
}

extension UserCard {
    static var placeholder: some View {
        HStack {
            ProfileImage(nil, size: 42, cornerRadius: 10)
            
            VStack {
                Text("Name")
                    .cfont(.body)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("@username")
                    .cfont(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.secondary)
                
            }
            
            RoundedRectangle(cornerRadius: 5)
                .foregroundStyle(.tertiary)
                .frame(width: 25, height: 28)
        }
        .redacted(reason: .placeholder)
    }
}


#Preview {
    UserSelectorView()
}
