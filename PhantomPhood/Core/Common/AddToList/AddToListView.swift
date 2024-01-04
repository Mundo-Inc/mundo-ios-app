//
//  AddToListView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/3/24.
//

import SwiftUI

struct AddToListView: View {
    @StateObject private var vm: AddToListVM
    @State var isAnimating = true
    
    private let placeName: String
    
    init(placeId: String, placeName: String, dismiss: @escaping () -> Void) {
        self._vm = StateObject(wrappedValue: AddToListVM(placeId: placeId, dismiss: dismiss))
        self.placeName = placeName
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(.rect)
                .onTapGesture {
                    vm.dismiss()
                }
            
            VStack(spacing: 0) {
                VStack {
                    Text("Add to List")
                        .font(.custom(style: .headline))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Adding **\(placeName)** to a list")
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
                                print("Called")
                                await vm.fetchLists()
                            }
                            print("Called2")
                            vm.isAddListPresented = false
                        } onCancel: {
                            vm.isAddListPresented = false
                        }
                    })
                    
                    ScrollView {
                        if !vm.isLoading {
                            ForEach(vm.lists) { list in
                                Button {
                                    vm.selectList(listId: list.id)
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
                                                if vm.selectedListIds.contains(list.id) {
                                                    Image(systemName: "checkmark.square.fill")
                                                        .foregroundStyle(Color.accentColor)
                                                }
                                            }
                                    }
                                    .padding(.all, 10)
                                    .background(vm.selectedListIds.contains(list.id) ? Color.accentColor.opacity(0.1) : Color.secondary.opacity(0.1))
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
                        vm.dismiss()
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
                            vm.dismiss()
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
