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
    
    init(onSuccess: @escaping (UserPlacesList) -> Void = { _ in }, onCancel: @escaping () -> Void = {}) {
        self._vm = StateObject(wrappedValue: CreateNewListVM(onSuccess: onSuccess, onCancel: onCancel))
    }
    
    @FocusState var focusedField: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Create a New List")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cfont(.headline)
                
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
                    ScrollView {
                        VStack(spacing: 30) {
                            VStack {
                                Text("Name your list")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .cfont(.headline)
                                Text("Choose a name for your list")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .cfont(.body)
                                    .foregroundStyle(.secondary)
                                
                                HStack {
                                    Button {
                                        vm.presentingSheet = .reactionSelector(onSelect: { reaction in
                                            vm.icon = reaction
                                        })
                                    } label: {
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundStyle(.themePrimary)
                                            .frame(width: 52, height: 52)
                                            .overlay {
                                                Emoji(vm.icon, isAnimating: $vm.isEmojiAnimating, size: 28)
                                            }
                                    }
                                    
                                    TextField("e.g. Want To Go", text: $vm.name)
                                        .focused($focusedField)
                                        .withFilledStyle(size: .large)
                                        .overlay(alignment: .bottomTrailing) {
                                            Text("\(vm.name.count)/16")
                                                .cfont(.caption)
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
                                        .cfont(.headline)
                                    Text(vm.isPrivate ? "Only collaborators can view" : "Everyone can view")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                        .cfont(.body)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .toggleStyle(.switch)
                            .tint(.accentColor)
                            
                            Spacer()
                        }
                        .padding()
                    }
                    .scrollIndicators(.never)
                    .scrollDismissesKeyboard(.immediately)
                case .collaborators:
                    VStack(spacing: 0) {
                        VStack {
                            Text("Members")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .cfont(.headline)
                            Text("Collaborate with others!")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .cfont(.body)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        
                        List {
                            if let currentUser = auth.currentUser {
                                HStack {
                                    ProfileImage(currentUser.profileImage, size: 36, cornerRadius: 18)
                                    Text(currentUser.name)
                                        .cfont(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("Owner")
                                        .cfont(.body)
                                        .foregroundStyle(.secondary)
                                        .padding(.trailing)
                                }
                                .frame(minHeight: 42)
                            }
                            
                            ForEach(vm.collaborators) { collaborator in
                                HStack {
                                    ProfileImage(collaborator.user.profileImage, size: 36, cornerRadius: 18)
                                    Text(collaborator.user.name)
                                        .cfont(.subheadline)
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
                                vm.presentingSheet = .userSelector(onSelect: { user in
                                    if !vm.collaborators.contains(where: { $0.user.id == user.id }) {
                                        vm.collaborators.append(.init(user: user, access: .edit))
                                    }
                                })
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
                                .cfont(.subheadline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 32)
                        }
                        .buttonStyle(.borderless)
                        
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
                                Text(vm.step == .general ? "Next" : "Create")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .cfont(.subheadline)
                        }
                        .buttonStyle(.borderedProminent)
                        .opacity(vm.isReadyToSubmit ? 1 : 0.6)
                        .disabled(!vm.isReadyToSubmit)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                }
            }
        }
        .sheet(item: $vm.presentingSheet) { item in
            switch item {
            case .userSelector(let onSelect):
                if #available(iOS 16.4, *) {
                    UserSelectorView(onSelect: onSelect)
                        .presentationBackground(.thinMaterial)
                } else {
                    UserSelectorView(onSelect: onSelect)
                }
            case .reactionSelector(let onSelect):
                if #available(iOS 16.4, *) {
                    SelectReactionsView(onSelect: onSelect)
                        .presentationBackground(.thinMaterial)
                } else {
                    SelectReactionsView(onSelect: onSelect)
                }
            }
        }
        .onAppear {
            focusedField = true
        }
        .onDisappear {
            vm.isEmojiAnimating = false
        }
    }
}

#Preview {
    CreateNewListView()
}
