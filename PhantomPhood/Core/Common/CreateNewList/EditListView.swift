//
//  EditListView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/8/24.
//

import SwiftUI

struct EditListView: View {
    @ObservedObject private var auth = Authentication.shared
    
    @StateObject private var vm: EditListVM
    
    @Environment(\.dismiss) private var dismiss
    
    // Creating new instance because of the sheet
    @StateObject var selectReactionsViewModel = SelectReactionsVM()
    
    init(originalList: UserPlacesList, onSuccess: @escaping (UserPlacesList) -> Void = { _ in }, onCancel: @escaping () -> Void = {}) {
        self._vm = StateObject(wrappedValue: EditListVM(originalList: originalList, onSuccess: onSuccess, onCancel: onCancel))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Editing \(vm.originalList.name)")
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
                switch vm.step {
                case .general:
                    VStack(spacing: 30) {
                        VStack {
                            Text("Name your list")
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
                        
                        Toggle(isOn: $vm.isPrivate) {
                            VStack {
                                Text(vm.isPrivate ? "Private" : "Public")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.custom(style: .headline))
                                Text(vm.isPrivate ? "Only collaborators can view" : "Everyone can view")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .font(.custom(style: .body))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .toggleStyle(.switch)
                        .tint(.accentColor)
                        
                        Spacer()
                    }
                    .padding()
                    
                case .collaborators:
                    VStack(spacing: 0) {
                        VStack {
                            Text("Members")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.custom(style: .headline))
                            Text("Collaborate with others!")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.custom(style: .body))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        
                        List {
                            HStack {
                                ProfileImage(vm.originalList.owner.profileImage, size: 36, cornerRadius: 18)
                                Text(vm.originalList.owner.name)
                                    .font(.custom(style: .headline))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("Owner")
                                    .font(.custom(style: .body))
                                    .foregroundStyle(.secondary)
                                    .padding(.trailing)
                            }
                            .frame(minHeight: 42)
                            
                            ForEach(vm.collaborators) { collaborator in
                                HStack {
                                    ProfileImage(collaborator.user.profileImage, size: 36, cornerRadius: 18)
                                    Text(collaborator.user.name)
                                        .font(.custom(style: .subheadline))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Picker(selection: Binding(get: {
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
                                            .tag(ListCollaborator.Access.edit)
                                        
                                        Text("Can View")
                                            .tag(ListCollaborator.Access.view)
                                    } label: {
                                        EmptyView()
                                    }
                                }
                                .frame(minHeight: 46)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        vm.collaborators = vm.collaborators.filter({ $0.user.id != collaborator.user.id })
                                    } label: {
                                        Text("Remove")
                                    }
                                    
                                }
                            }
                            
                            Button {
                                vm.showAddListCollaborators = true
                            } label: {
                                Label {
                                    Text("Add Member")
                                } icon: {
                                    Image(systemName: "plus")
                                }
                                
                            }
                        }
                    }
                    .padding(.vertical)
                }
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Button {
                            switch vm.step {
                            case .general:
                                vm.onCancel()
                            case .collaborators:
                                withAnimation {
                                    vm.step = .general
                                }
                            }
                        } label: {
                            Text(vm.step == .general ? "Cancel" : "Back")
                                .font(.custom(style: .subheadline))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderless)
                        .controlSize(.large)
                        
                        Button {
                            switch vm.step {
                            case .general:
                                withAnimation {
                                    vm.step = .collaborators
                                }
                            case .collaborators:
                                Task {
                                    await vm.submit()
                                }
                            }
                        } label: {
                            HStack(spacing: 5) {
                                if vm.isLoading {
                                    ProgressView()
                                        .controlSize(.regular)
                                }
                                Text(vm.step == .general ? "Next" : "Update")
                            }
                            .font(.custom(style: .subheadline))
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .opacity(vm.isReadyToSubmit ? 1 : 0.6)
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
                UserSelector(onSelect: { user in
                    if !vm.collaborators.contains(where: { $0.user.id == user.id }) {
                        vm.collaborators.append(.init(user: user, access: .edit))
                    }
                    vm.showAddListCollaborators = false
                }, onCancel: {
                    vm.showAddListCollaborators = false
                })
                .presentationBackground(.thinMaterial)
            } else {
                UserSelector(onSelect: { user in
                    if !vm.collaborators.contains(where: { $0.user.id == user.id }) {
                        vm.collaborators.append(.init(user: user, access: .edit))
                    }
                    vm.showAddListCollaborators = false
                }, onCancel: {
                    vm.showAddListCollaborators = false
                })
            }
        })
        .onDisappear {
            vm.isEmojiAnimating = false
        }
    }
}
