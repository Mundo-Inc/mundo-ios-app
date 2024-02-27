//
//  AddListCollaboratorView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/2/24.
//

import SwiftUI

struct UserSelector: View {
    @StateObject private var vm: UserSelectorVM
    
    init(onSelect: @escaping (UserEssentials) -> Void = { _ in }) {
        self._vm = StateObject(wrappedValue: UserSelectorVM(onSelect: onSelect))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if vm.searchResults.isEmpty {
                    if vm.isLoading {
                        ProgressView()
                            .padding(.top)
                    } else {
                        Text("No results")
                            .font(.custom(style: .body))
                            .padding(.horizontal)
                    }
                } else {
                    LazyVStack {
                        ForEach(vm.searchResults) { user in
                            UserCard(user: user, onSelect: vm.onSelect)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Add New Collaborators")
            .navigationBarTitleDisplayMode(.inline)
        }
        .searchable(text: $vm.searchText, placement: .navigationBarDrawer(displayMode: .always))
    }
}

fileprivate struct UserCard: View {
    let user: UserEssentials
    
    let onSelect: (UserEssentials) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
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
                                .font(.custom(style: .body))
                                .bold()
                            Image(systemName: "checkmark.seal")
                                .font(.system(size: 12))
                                .foregroundStyle(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    } else {
                        Text(user.name)
                            .font(.custom(style: .body))
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Text("@" + user.username)
                        .font(.custom(style: .caption))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.secondary)
                    
                }
                
                LevelView(level: user.progress.level)
                    .frame(width: 28, height: 28)
            }
        }
        .foregroundStyle(.primary)
    }
}


#Preview {
    UserSelector()
}
