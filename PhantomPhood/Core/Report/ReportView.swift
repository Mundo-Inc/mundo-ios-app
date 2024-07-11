//
//  ReportView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/27/23.
//

import SwiftUI

struct ReportView: View {
    @StateObject private var vm: ReportVM
    
    @Environment(\.dismiss) private var dismiss
    
    init(item: ReportDM.ReportType) {
        self._vm = StateObject(wrappedValue: ReportVM(item: item))
    }
    
    var body: some View {
        ZStack {
            Color.themeBG
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            if vm.step == 0 {
                ScrollView {
                    ForEach(ReportDM.FlagType.allCases, id: \.self) { flag in
                        Button {
                            withAnimation {
                                vm.flagType = flag
                                vm.step += 1
                            }
                        } label: {
                            Text(flag.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                                .frame(maxWidth: .infinity)
                        }
                        .controlSize(.large)
                        .buttonStyle(.borderedProminent)
                        .tint(vm.flagType == flag ? Color.accentColor : Color.themePrimary)
                        .foregroundStyle(vm.flagType == flag ? Color.white : Color.primary)
                    }
                }
                .scrollIndicators(.hidden)
                .padding(.horizontal)
                .cfont(.body)
            } else if vm.step == 1 {
                VStack {
                    TextField("Any notes on this (Optional)", text: $vm.note, axis: .vertical)
                        .lineLimit(6...10)
                        .padding()
                        .background(Color.themePrimary.clipShape(.rect(cornerRadius: 10)))
                        .overlay {
                            if vm.note.count > 0 {
                                Text("\(vm.note.count)/250")
                                    .cfont(.caption)
                                    .foregroundStyle(vm.note.count > 250 ? .red : Color.secondary)
                                    .padding(.bottom, 8)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            }
                        }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Report \(vm.item.title)")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if vm.step == 0 {
                        withAnimation {
                            vm.step += 1
                        }
                    } else if vm.step == 1 {
                        Task {
                            await vm.submit()
                            dismiss()
                        }
                    }
                } label: {
                    Text(vm.step == 0 ? "Next" : "Submit")
                        .cfont(.body)
                }
                .buttonStyle(.bordered)
            }
        }
        .transition(.move(edge: .bottom))
    }
}

#Preview {
    ReportView(item: .activity("TestId"))
}
