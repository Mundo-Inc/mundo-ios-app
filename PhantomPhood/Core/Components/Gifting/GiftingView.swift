//
//  GiftingView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/30/24.
//

import SwiftUI

struct GiftingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: GiftingVM
    
    init(_ idOrData: IdOrData<UserEssentials>) {
        switch idOrData {
        case .id(let userId):
            self._vm = StateObject(wrappedValue: GiftingVM(userId: userId))
        case .data(let user):
            self._vm = StateObject(wrappedValue: GiftingVM(user: user))
        }
    }
    
    @FocusState private var isCustomAmountFocused
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 15) {
                Text("You are gifting")
                    .font(.custom(style: .title2))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    ProfileImage(vm.user?.profileImage, size: 50)
                    
                    VStack(alignment: .leading) {
                        Text(vm.user?.name ?? "Name")
                            .font(.custom(style: .headline))
                            .fontWeight(.bold)
                        
                        Text("@\(vm.user?.username ?? "username")")
                            .font(.custom(style: .caption))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .redacted(reason: vm.user == nil ? .placeholder : [])
                }
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.top, 15)
            
            ScrollView {
                Text("Please choose or enter an amount to continue")
                    .foregroundStyle(.secondary)
                    .padding(.top, 15)
                
                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        ForEach(GiftingVM.defaultOptions.indices, id: \.self) { index in
                            Button {
                                vm.customAmount = ""
                                vm.selectionIndex = index
                            } label: {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundStyle(vm.selectionIndex == index ? Color.accentColor : Color.themeBorder)
                                    .animation(.spring, value: vm.selectionIndex)
                                    .frame(maxWidth: .infinity)
                                    .aspectRatio(1, contentMode: .fit)
                                    .overlay {
                                        HStack(spacing: 0) {
                                            Image(systemName: "dollarsign")
                                                .font(.system(size: 16))
                                                .fontWeight(.medium)
                                                .foregroundStyle(vm.selectionIndex == index ? Color.black : Color.secondary)
                                            
                                            Text(GiftingVM.defaultOptions[index].formatted())
                                                .font(.custom(style: .title3))
                                                .foregroundStyle(vm.selectionIndex == index ? Color.black : Color.primary)
                                        }
                                    }
                                    .animation(.easeOut(duration: 0.1), value: vm.selectionIndex)
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                    
                    TextField("Custom Amount", text: $vm.customAmount)
                        .focused($isCustomAmountFocused)
                        .font(.custom(style: .title3))
                        .withFilledStyle(size: .large, color: Color.themeBorder, paddingLeading: 50)
                        .keyboardType(.decimalPad)
                        .textContentType(.none)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .overlay(alignment: .leading) {
                            Image(systemName: "dollarsign")
                                .font(.system(size: 18))
                                .fontWeight(.medium)
                                .padding(.leading, 15)
                                .foregroundStyle(.tertiary)
                        }
                }
                
                VStack(alignment: .leading) {
                    Text("Payment method")
                    
                    Button {
                        if isCustomAmountFocused {
                            isCustomAmountFocused = false
                            vm.presentPaymentSheet()
                        } else {
                            vm.presentPaymentSheet()
                        }
                    } label: {
                        Group {
                            if let selectedPaymentOption = vm.selectedPaymentOption {
                                switch selectedPaymentOption {
                                case .applePay(let paymentOptionDisplayData):
                                    HStack {
                                        Image(uiImage: paymentOptionDisplayData.image)
                                        
                                        Text(paymentOptionDisplayData.label)
                                            .monospaced()
                                        
                                        Spacer()
                                        
                                        Text("CHANGE")
                                            .font(.custom(style: .caption))
                                            .foregroundStyle(Color.accentColor)
                                    }
                                case .paymentMethod(_, let paymentOptionDisplayData):
                                    HStack {
                                        Image(uiImage: paymentOptionDisplayData.image)
                                        
                                        Text(paymentOptionDisplayData.label)
                                            .monospaced()
                                        
                                        Spacer()
                                        
                                        Text("CHANGE")
                                            .font(.custom(style: .caption))
                                            .foregroundStyle(Color.accentColor)
                                    }
                                }
                            } else {
                                Label {
                                    Text("Add a payment method")
                                } icon: {
                                    Image(systemName: "plus")
                                }
                                .redacted(reason: vm.loadingSections.contains(.retrievePaymentOptionSelection) ? .placeholder : [])
                                .foregroundStyle(Color.accentColor)
                            }
                        }
                        .font(.custom(style: .body))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.themeBorder, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .foregroundStyle(.primary)
                    .disabled(vm.loadingSections.contains(.retrievePaymentOptionSelection))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 15)
                
                VStack(alignment: .leading) {
                    Text("Message")
                    
                    TextField("Add a custom message (Optional)", text: $vm.message, axis: .vertical)
                        .lineLimit(3...8)
                        .disabled(vm.loadingSections.contains(.submitting))
                        .padding()
                        .background(Color.themeBorder, in: RoundedRectangle(cornerRadius: 12))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 15)
            }
            .scrollDismissesKeyboard(.immediately)
            .scrollIndicators(.hidden)
            .padding(.horizontal)
            .customerSheet(isPresented: $vm.isPaymentsSheetPresented, customerSheet: vm.customerSheet, onCompletion: vm.onPaymentMethodCompletion)
            
            if let giftAmount = vm.giftAmount {
                CTAButton {
                    Task {
                        await vm.submit { _ in
                            dismiss()
                        }
                    }
                } label: {
                    HStack {
                        if vm.loadingSections.contains(.submitting) {
                            ProgressView()
                                .controlSize(.regular)
                                .padding(.trailing, 3)
                                .transition(AnyTransition.opacity)
                        }
                        
                        Text("SEND GIFT ($\(giftAmount.formatted()))")
                    }
                }
                .disabled(!vm.loadingSections.isEmpty || vm.selectedPaymentOption == nil)
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .presentationDetents([.fraction(0.9)])
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var isPresented = true
        
        var body: some View {
            NavigationStack {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                        .sheet(isPresented: $isPresented) {
                            if #available(iOS 16.4, *) {
                                GiftingView(.data(UserEssentials(
                                    id: "645c8b222134643c020860a5",
                                    name: "Kia Abdi",
                                    username: "TheKia",
                                    verified: true,
                                    isPrivate: false,
                                    profileImage: URL(string: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg")!,
                                    progress: .init(level: 35, xp: 2000)
                                )))
                                .presentationBackground(.thinMaterial)
                            } else {
                                GiftingView(.data(UserEssentials(
                                    id: "645c8b222134643c020860a5",
                                    name: "Kia Abdi",
                                    username: "TheKia",
                                    verified: true,
                                    isPrivate: false,
                                    profileImage: URL(string: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg")!,
                                    progress: .init(level: 35, xp: 2000)
                                )))
                            }
                        }
                    
                    Button {
                        isPresented = true
                    } label: {
                        Text("Present")
                    }
                }
            }
        }
    }
    
    return PreviewWrapper()
}
