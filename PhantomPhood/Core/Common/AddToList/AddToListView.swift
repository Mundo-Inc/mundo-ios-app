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
    
    init(placeVM: PlaceVM, placeId: String) {
        self._vm = StateObject(wrappedValue: AddToListVM(placeVM: placeVM, placeId: placeId))
        self._placeVM = ObservedObject(wrappedValue: placeVM)
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(.rect)
                .onTapGesture {
                    withAnimation {
                        placeVM.isAddToListPresented = false
                    }
                }
            
            VStack(spacing: 0) {
                VStack {
                    Text("Add to List")
                        .font(.custom(style: .headline))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Adding **\(placeVM.place?.name ?? "Place Name")** to a list")
                        .font(.custom(style: .body))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button {
                        vm.isAddListPresented = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.app")
                                .font(.system(size: 22))
                            Text("Create a new list")
                                .font(.custom(style: .body))
                            
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
                    
                    ScrollView {
                        if let includedLists = placeVM.includedLists, !vm.isLoading {
                            ForEach(vm.lists) { list in
                                Button {
                                    if includedLists.contains(where: { $0 == list.id }) {
                                        vm.addAction(item: .init(id: list.id, action: .remove))
                                    } else {
                                        vm.addAction(item: .init(id: list.id, action: .add))
                                    }
                                } label: {
                                    HStack {
                                        Circle()
                                            .foregroundStyle(.themeBorder)
                                            .frame(width: 32, height: 32)
                                            .overlay {
                                                Emoji(symbol: list.icon, isAnimating: $isAnimating, size: 18)
                                            }
                                        Text(list.name)
                                        Text("(\(list.placesCount))")
                                        
                                        Spacer()
                                        
                                        RoundedRectangle(cornerRadius: 5)
                                            .frame(width: 20, height: 20)
                                            .foregroundStyle(.secondary.opacity(0.2))
                                            .overlay {
                                                if vm.isItemSelected(includedLists: includedLists, listId: list.id) {
                                                    Image(systemName: "checkmark.square.fill")
                                                        .foregroundStyle(Color.accentColor)
                                                }
                                            }
                                    }
                                    .padding(.all, 10)
                                    .background(vm.isItemSelected(includedLists: includedLists, listId: list.id) ? Color.accentColor.opacity(0.1) : Color.secondary.opacity(0.1))
                                    .clipShape(.rect(cornerRadius: 8))
                                }
                                .foregroundStyle(.primary)
                                .disabled(vm.isLoading)
                            }
                        } else {
                            // Placeholder
                            HStack {
                                Circle()
                                    .foregroundStyle(.themeBorder)
                                    .frame(width: 32, height: 32)
                                    .overlay {
                                        Emoji(symbol: "❤️", isAnimating: $isAnimating, size: 18)
                                    }
                                Text("List Name")
                                Text("(1)")
                                
                                Spacer()
                                
                                RoundedRectangle(cornerRadius: 5)
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.secondary.opacity(0.2))
                            }
                            .padding(.all, 10)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(.rect(cornerRadius: 8))
                            .redacted(reason: .placeholder)
                        }
                    }
                    .frame(height: 250)
                }
                .padding(.horizontal)
                
                Divider()
                
                HStack {
                    Spacer()
                    
                    Button {
                        withAnimation {
                            placeVM.isAddToListPresented = false
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
                                placeVM.isAddToListPresented = false
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
        .redacted(reason: placeVM.place == nil ? .placeholder : [])
        .frame(maxHeight: .infinity)
        .background(.thinMaterial)
        .onDisappear {
            self.isAnimating = false
        }
        .onAppear {
            self.isAnimating = true
        }
    }
}
