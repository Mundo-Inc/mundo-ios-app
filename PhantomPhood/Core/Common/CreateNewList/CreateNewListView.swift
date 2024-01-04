//
//  CreateNewListView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/29/23.
//

import SwiftUI

struct CreateNewListView: View {
    @ObservedObject private var auth = Authentication.shared
    
    @StateObject private var vm: CreateNewListVM
    
    @Environment(\.dismiss) private var dismiss
    
    // Creating new instance because of the sheet
    @StateObject var selectReactionsViewModel = SelectReactionsVM()
    
    init(onSuccess: @escaping (UserPlacesList) -> Void = { _ in }, onCancel: @escaping () -> Void = {}) {
        self._vm = StateObject(wrappedValue: CreateNewListVM(onSuccess: onSuccess, onCancel: onCancel))
    }
    
    enum TextFields: Hashable {
        case name
    }
    @FocusState var focusedField: TextFields?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Create a New List")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom(style: .headline))
                
                Button {
                    vm.onCancel()
                } label: {
                    Image(systemName: "xmark")
                }
            }
            .padding()
            
            Divider()
            
            ZStack {
                ScrollView {
                    VStack(spacing: 30) {
                        VStack {
                            Text("Name your Lsit")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.custom(style: .headline))
                            Text("Choose a name for your list")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.custom(style: .body))
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                Button {
                                    selectReactionsViewModel.select { emoji in
                                        vm.icon = emoji
                                    }
                                } label: {
                                    RoundedRectangle(cornerRadius: 8)
                                        .foregroundStyle(.themePrimary)
                                        .frame(width: 52, height: 52)
                                        .overlay {
                                            Emoji(vm.icon, isAnimating: $vm.isEmojiAnimating, size: 28)
                                        }
                                }
                                
                                TextField("e.g. Want To Go", text: $vm.name)
                                    .focused($focusedField, equals: TextFields.name)
                                    .withFilledStyle(size: .large)
                                    .overlay(alignment: .bottomTrailing) {
                                        Text("\(vm.name.count)/16")
                                            .font(.custom(style: .caption))
                                            .padding(.trailing, 8)
                                            .padding(.bottom, 4)
                                            .foregroundStyle(vm.name.count <= 16 ? Color.secondary : Color.red)
                                            .opacity(0.7)
                                    }
                            }
                        }
                        
                        HStack {
                            VStack {
                                Text("Public List")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.custom(style: .headline))
                                Text("Others can view your list")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                    .font(.custom(style: .body))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Toggle(isOn: $vm.isPublic) {
                                EmptyView()
                            }
                            .toggleStyle(.switch)
                            .tint(.accentColor)
                        }
                        
                        VStack {
                            HStack {
                                VStack {
                                    Text("Members")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.custom(style: .headline))
                                    Text("Collaborate with others!")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.custom(style: .body))
                                        .foregroundStyle(.secondary)
                                }
                                
                                Button {
                                    vm.showAddListCollaborators = true
                                } label: {
                                    Text("Add Member")
                                        .font(.custom(style: .headline))
                                }
                                .foregroundStyle(Color.accentColor)
                            }
                            
                            if let currentUser = auth.currentUser {
                                HStack {
                                    ProfileImage(currentUser.profileImage, size: 36, cornerRadius: 18)
                                    Text(currentUser.name)
                                        .font(.custom(style: .headline))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("Owner")
                                        .font(.custom(style: .body))
                                        .foregroundStyle(.secondary)
                                        .padding(.trailing)
                                }
                            }
                            ForEach(vm.collaborators) { collaborator in
                                HStack {
                                    ProfileImage(collaborator.user.profileImage, size: 36, cornerRadius: 18)
                                    Text(collaborator.user.name)
                                        .font(.custom(style: .subheadline))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Picker("Access", selection: Binding(get: {
                                        collaborator.access
                                    }, set: { access in
                                        vm.collaborators = vm.collaborators.map({ c in
                                            if c.id == collaborator.id {
                                                return .init(user: c.user, access: access)
                                            }
                                            return c
                                        })
                                    })) {
                                        Text("Can Edit")
                                            .tag(ListCollaboratorAccess.edit)
                                        
                                        Text("Can View")
                                            .tag(ListCollaboratorAccess.view)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                .scrollDismissesKeyboard(.immediately)
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Button {
                            vm.onCancel()
                        } label: {
                            Text("Cancel")
                                .font(.custom(style: .subheadline))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderless)
                        .controlSize(.large)
                        
                        Button {
                            Task {
                                await vm.submit()
                            }
                        } label: {
                            HStack(spacing: 5) {
                                if vm.isLoading {
                                    ProgressView()
                                        .controlSize(.regular)
                                }
                                Text("Create")
                            }
                            .font(.custom(style: .subheadline))
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(!vm.isReadyToSubmit)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                }
            }
        }
        .sheet(isPresented: $selectReactionsViewModel.isPresented, content: {
            if #available(iOS 17.0, *) {
                SelectReactionsView(vm: selectReactionsViewModel)
                    .presentationBackground(.thinMaterial)
            } else {
                SelectReactionsView(vm: selectReactionsViewModel)
            }
        })
        .sheet(isPresented: $vm.showAddListCollaborators, content: {
            if #available(iOS 17.0, *) {
                AddListCollaboratorView(onSelect: { user in
                    if !vm.collaborators.contains(where: { $0.user.id == user.id }) {
                        vm.collaborators.append(.init(user: user, access: .edit))
                    }
                    vm.showAddListCollaborators = false
                }, onCancel: {
                    vm.showAddListCollaborators = false
                })
                .presentationBackground(.thinMaterial)
            } else {
                AddListCollaboratorView(onSelect: { user in
                    if !vm.collaborators.contains(where: { $0.user.id == user.id }) {
                        vm.collaborators.append(.init(user: user, access: .edit))
                    }
                    vm.showAddListCollaborators = false
                }, onCancel: {
                    vm.showAddListCollaborators = false
                })
            }
        })
        .onAppear {
            if vm.name.isEmpty {
                focusedField = .name
            }
        }
        .onDisappear {
            vm.isEmojiAnimating = false
        }
    }
}

#Preview {
    CreateNewListView()
}
