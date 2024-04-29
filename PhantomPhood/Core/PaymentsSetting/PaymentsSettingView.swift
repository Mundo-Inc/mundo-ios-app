//
//  PaymentsSettingView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/29/24.
//

import SwiftUI
import StripePaymentSheet

struct PaymentsSettingView: View {
    @StateObject private var vm = PaymentsSettingVM()
    
    var body: some View {
        List {
            Section("Default Payment Method") {
                if let selectedPaymentOption = vm.selectedPaymentOption {
                    switch selectedPaymentOption {
                    case .applePay(let paymentOptionDisplayData):
                        Label {
                            Text(paymentOptionDisplayData.label)
                        } icon: {
                            Image(uiImage: paymentOptionDisplayData.image)
                        }
                    case .paymentMethod(_, let paymentOptionDisplayData):
                        Label {
                            Text(paymentOptionDisplayData.label)
                        } icon: {
                            Image(uiImage: paymentOptionDisplayData.image)
                        }
                    }
                } else {
                    Label {
                        Text("Not set")
                    } icon: {
                        Image(systemName: "xmark.app")
                    }
                    .redacted(reason: vm.loadingSections.contains(.retrievePaymentOptionSelection) ? .placeholder : [])
                }
                
                Button {
                    vm.presentPaymentSheet()
                } label: {
                    Label("Add / Edit", systemImage: "creditcard")
                }
                .customerSheet(isPresented: $vm.isPaymentsSheetPresented, customerSheet: vm.customerSheet, onCompletion: vm.onPaymentMethodCompletion)
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Payments")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    PaymentsSettingView()
}
