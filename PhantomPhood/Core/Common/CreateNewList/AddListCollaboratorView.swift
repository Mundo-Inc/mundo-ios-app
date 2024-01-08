//
//  AddListCollaboratorView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/2/24.
//

import SwiftUI

struct AddListCollaboratorView: View {
    @StateObject private var vm: AddListCollaboratorVM
    
    init(onSelect: @escaping (CompactUser) -> Void = { _ in }, onCancel: @escaping () -> Void = {}) {
        self._vm = StateObject(wrappedValue: AddListCollaboratorVM(onSelect: onSelect, onCancel: onCancel))
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
    let user: CompactUser
    
    let onSelect: (CompactUser) -> Void
    
    var body: some View {
        Button {
            self.onSelect(user)
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
    AddListCollaboratorView()
}
