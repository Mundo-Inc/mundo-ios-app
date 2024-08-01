//
//  UserSelectorView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/2/24.
//

import SwiftUI

struct UserSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var vm = UserSelectorVM()
    
    private let onSelect: (UserEssentials) -> Void
    
    init(onSelect: @escaping (UserEssentials) -> Void) {
        self.onSelect = onSelect
    }
    
    @FocusState private var textFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Select a User")
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                
                Text("Choose a user to add")
                    .cfont(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 0) {
                    Image(.Icons.search)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22)
                        .frame(width: 46, height: 46)
                        .foregroundStyle(.tertiary)
                    
                    TextField("Search Users", text: $vm.searchText)
                        .frame(maxWidth: .infinity)
                        .textInputAutocapitalization(.never)
                        .focused($textFocused)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Color.themePrimary, in: .rect(cornerRadius: 50))
                .contentShape(RoundedRectangle(cornerRadius: 50))
                .onTapGesture {
                    textFocused = true
                }
                .padding(.top, 8)
            }
            .padding()
            .padding(.top, 8)
            
            Divider()
                .padding(.horizontal)
            
            if vm.searchResults.isEmpty && vm.isLoading {
                List {
                    UserCard.placeholder
                    UserCard.placeholder
                    UserCard.placeholder
                    UserCard.placeholder
                    UserCard.placeholder
                    UserCard.placeholder
                    UserCard.placeholder
                    UserCard.placeholder
                }
                .listStyle(PlainListStyle())
                .scrollDismissesKeyboard(.interactively)
                .opacity(0.6)
            } else {
                List(vm.searchResults, id: \.self) { user in
                    UserCard(user: user, onSelect: onSelect)
                }
                .listStyle(PlainListStyle())
                .scrollDismissesKeyboard(.interactively)
                .opacity(vm.isLoading ? 0.6 : 1)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            textFocused = true
        }
    }
}

fileprivate struct UserCard: View {
    @Environment(\.dismiss) private var dismiss
    
    private let user: UserEssentials
    private let onSelect: (UserEssentials) -> Void
    
    init(user: UserEssentials, onSelect: @escaping (UserEssentials) -> Void) {
        self.user = user
        self.onSelect = onSelect
    }
    
    var body: some View {
        Button {
            dismiss()
            onSelect(user)
        } label: {
            HStack {
                ProfileImage(user.profileImage, size: 42, cornerRadius: 10)
                
                VStack {
                    Group {
                        if (user.verified) {
                            HStack {
                                Text(user.name)
                                
                                Image(systemName: "checkmark.seal")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.blue)
                            }
                        } else {
                            Text(user.name)
                        }
                    }
                    .cfont(.body)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 18)
                    
                    Text("@" + user.username)
                        .cfont(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                LevelView(level: user.progress.level)
                    .frame(width: 25, height: 25)
            }
        }
        .foregroundStyle(.primary)
        .listRowBackground(Color.clear)
        .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
        .alignmentGuide(.listRowSeparatorTrailing) { $0[.trailing] }
    }
    
    static var placeholder: some View {
        HStack {
            ProfileImage(nil, size: 42, cornerRadius: 10)
            
            VStack {
                Text("Placeholder Name")
                    .cfont(.body)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 18)
                
                Text("@username")
                    .foregroundStyle(.secondary)
                    .cfont(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            RoundedRectangle(cornerRadius: 5)
                .foregroundStyle(.tertiary)
                .frame(width: 25, height: 25)
        }
        .redacted(reason: .placeholder)
        .foregroundStyle(.primary)
        .listRowBackground(Color.clear)
        .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
        .alignmentGuide(.listRowSeparatorTrailing) { $0[.trailing] }
    }
}


#Preview {
    UserSelectorView { user in
        print(user)
    }
}
