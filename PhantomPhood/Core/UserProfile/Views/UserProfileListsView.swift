//
//  UserProfileListsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/4/24.
//

import SwiftUI

struct UserProfileListsView: View {
    @StateObject private var vm: UserProfileListsVM
    
    init(user: UserDetail) {
        self._vm = StateObject(wrappedValue: UserProfileListsVM(userId: user.id))
    }
    
    @State var isAnimating = true
    
    var body: some View {
        VStack {
            Button {
                vm.isAddListPresented = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                    Text("Create a new list")
                        .font(.custom(style: .headline))
                }
                .foregroundStyle(Color.accentColor)
                .frame(height: 86)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(.themePrimary)
                }
            }
            .fullScreenCover(isPresented: $vm.isAddListPresented, content: {
                CreateNewListView { list in
                    vm.isAddListPresented = false
                    Task {
                        await vm.fetchLists()
                    }
                } onCancel: {
                    vm.isAddListPresented = false
                }
            })
            
            
            if vm.isLoading {
                ListItemPlaceholder()
            } else {
                if vm.lists.isEmpty {
                    Text("- No Lists -")
                        .font(.custom(style: .headline))
                        .foregroundStyle(.secondary)
                        .padding(.top)
                } else {
                    ForEach(vm.lists) { list in
                        NavigationLink(value: AppRoute.placesList(listId: list.id)) {
                            HStack {
                                Circle()
                                    .foregroundStyle(.themeBorder)
                                    .frame(width: 54, height: 54)
                                    .overlay {
                                        Emoji(symbol: list.icon, isAnimating: $isAnimating, size: 28)
                                    }
                                
                                VStack {
                                    HStack {
                                        if list.isPrivate {
                                            Image(systemName: "lock.fill")
                                        }
                                        
                                        Text(list.name)
                                            .font(.custom(style: .headline))
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    
                                    HStack {
                                        Image(systemName: "person.2")
                                        
                                        Text(list.collaboratorsCount.description)
                                            .font(.custom(style: .body))
                                        
                                        Spacer()
                                    }
                                    .foregroundStyle(.secondary)
                                }
                                
                                Label {
                                    Text(list.placesCount.description)
                                        .font(.custom(style: .title2))
                                } icon: {
                                    Image(systemName: "mappin.circle")
                                        .font(.system(size: 20))
                                }
                                .padding(.trailing)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 16)
                            .background(.themePrimary)
                            .clipShape(.rect(cornerRadius: 16))
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.bottom)
        .font(.custom(style: .body))
        .onDisappear {
            self.isAnimating = false
        }
        .onAppear {
            self.isAnimating = true
        }
    }
}

fileprivate struct ListItemPlaceholder: View {
    var body: some View {
        HStack {
            Circle()
                .foregroundStyle(.themeBorder)
                .frame(width: 54, height: 54)
                .overlay {
                    Emoji(symbol: "❤️", isAnimating: .constant(false), size: 28)
                        .redacted(reason: .placeholder)
                }
            
            VStack {
                Text("List Name")
                    .font(.custom(style: .headline))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .redacted(reason: .placeholder)
                
                HStack {
                    Label {
                        Text("Public")
                    } icon: {
                        Image(systemName: "lock.open.fill")
                    }
                    .redacted(reason: .placeholder)
                    
                    Label {
                        Text("2")
                            .redacted(reason: .placeholder)
                    } icon: {
                        Image(systemName: "person.2")
                    }
                    .padding(.leading, 5)
                    
                    Spacer()
                }
                .font(.custom(style: .body))
                .foregroundStyle(.secondary)
            }
            
            Label {
                Text("2")
                    .font(.custom(style: .title2))
                    .redacted(reason: .placeholder)
            } icon: {
                Image(systemName: "mappin.circle")
                    .font(.system(size: 20))
            }
            .padding(.trailing)
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(.themePrimary)
        .clipShape(.rect(cornerRadius: 16))
    }
}
