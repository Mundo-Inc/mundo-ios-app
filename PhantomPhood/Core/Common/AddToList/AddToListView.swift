//
//  AddToListView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/3/24.
//

import SwiftUI

struct AddToListView: View {
    @StateObject private var vm: AddToListVM
    @ObservedObject private var placeVM: PlaceVM
    
    @State var isAnimating = true
    
    init(placeVM: PlaceVM) {
        self._vm = StateObject(wrappedValue: AddToListVM(placeVM: placeVM))
        self._placeVM = ObservedObject(wrappedValue: placeVM)
    }
    
    private var PlaceHolderItem: some View {
        HStack {
            RoundedRectangle(cornerRadius: 4)
                .foregroundStyle(Color.secondary.opacity(0.2))
                .frame(width: 36)
                .overlay {
                    Emoji(symbol: "❤️", isAnimating: $isAnimating, size: 18)
                }
            
            
            VStack(alignment: .leading, spacing: 2) {
                Text("List Name")
                
                Label {
                    Text("x1")
                } icon: {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 12))
                }
                .cfont(.caption)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            RoundedRectangle(cornerRadius: 5)
                .frame(width: 20, height: 20)
                .foregroundStyle(.secondary.opacity(0.2))
        }
        .padding(.all, 10)
        .background(Color.secondary.opacity(0.1))
        .clipShape(.rect(cornerRadius: 8))
        .redacted(reason: .placeholder)
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(.rect)
                .onTapGesture {
                    withAnimation {
                        placeVM.presentedSheet = nil
                    }
                }
            
            VStack(spacing: 0) {
                VStack {
                    Text("Lists")
                        .cfont(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Add/Remove **\(placeVM.place?.name ?? "Place Name")** from Your Lists")
                        .foregroundStyle(.secondary)
                        .cfont(.body)
                        .fontWeight(.regular)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button {
                        vm.isAddListPresented = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.app")
                                .font(.system(size: 22))
                            Text("Create a new list")
                                .cfont(.body)
                            
                            Spacer()
                        }
                        .foregroundStyle(Color.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary, style: StrokeStyle(lineWidth: 1, dash: [5]))
                        }
                    }
                    .fullScreenCover(isPresented: $vm.isAddListPresented, content: {
                        CreateNewListView { list in
                            Task {
                                await vm.fetchLists()
                            }
                            vm.isAddListPresented = false
                        } onCancel: {
                            vm.isAddListPresented = false
                        }
                    })
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                Divider()
                
                ScrollView {
                    VStack {
                        if let includedLists = placeVM.includedLists, let lists = vm.lists {
                            ForEach(lists) { list in
                                Button {
                                    if includedLists.contains(where: { $0 == list.id }) {
                                        vm.addAction(item: .init(id: list.id, action: .remove))
                                    } else {
                                        vm.addAction(item: .init(id: list.id, action: .add))
                                    }
                                } label: {
                                    HStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .foregroundStyle(Color.secondary.opacity(0.2))
                                            .frame(width: 36)
                                            .overlay {
                                                Emoji(symbol: list.icon, isAnimating: $isAnimating, size: 20)
                                            }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(list.name)
                                            
                                            Label {
                                                Text(list.placesCount.description)
                                            } icon: {
                                                Image(systemName: "mappin.and.ellipse")
                                                    .font(.system(size: 12))
                                            }
                                            .cfont(.caption)
                                            .foregroundStyle(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        if vm.isItemSelected(includedLists: includedLists, listId: list.id) {
                                            RoundedRectangle(cornerRadius: 5)
                                                .frame(width: 20, height: 20)
                                                .foregroundStyle(Color.accentColor.opacity(0.2))
                                                .overlay {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 12))
                                                        .foregroundStyle(Color.accentColor)
                                                }
                                        } else {
                                            RoundedRectangle(cornerRadius: 5)
                                                .frame(width: 20, height: 20)
                                                .foregroundStyle(.secondary.opacity(0.2))
                                        }
                                    }
                                    .padding(.all, 10)
                                    .background(vm.isItemSelected(includedLists: includedLists, listId: list.id) ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.1))
                                    .clipShape(.rect(cornerRadius: 8))
                                }
                                .foregroundStyle(.primary)
                                .disabled(vm.isLoading)
                            }
                        } else {
                            PlaceHolderItem
                            PlaceHolderItem
                            PlaceHolderItem
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)
                .frame(height: 250)
                
                Divider()
                
                HStack {
                    Spacer()
                    
                    Button {
                        withAnimation {
                            placeVM.presentedSheet = nil
                        }
                    } label: {
                        Text("Cancel")
                            .padding()
                    }
                    .foregroundStyle(.secondary)
                    .disabled(vm.isLoading)
                    
                    Divider()
                        .frame(height: 30)
                    
                    Button {
                        Task {
                            await vm.submit()
                            withAnimation {
                                placeVM.presentedSheet = nil
                            }
                        }
                    } label: {
                        Text("Save")
                            .padding()
                    }
                    .foregroundStyle(Color.accentColor)
                    .disabled(vm.isLoading)
                }
                .padding(.horizontal)
            }
            .padding(.top)
            .background(Color.themePrimary)
            .clipShape(.rect(cornerRadius: 16))
            .padding(.horizontal)
        }
        .cfont(.body)
        .redacted(reason: placeVM.place == nil ? .placeholder : [])
        .frame(maxHeight: .infinity)
        .onDisappear {
            self.isAnimating = false
        }
        .onAppear {
            self.isAnimating = true
        }
    }
}
