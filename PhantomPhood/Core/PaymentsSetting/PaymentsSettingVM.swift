//
//  PaymentsSettingVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/29/24.
//

import Foundation
import StripePaymentSheet

final class PaymentsSettingVM: LoadingSections, ObservableObject {
    static let transactionsDM = TransactionsDM()
    
    private(set) var customerAdapter: StripeCustomerAdapter
    private(set) var customerSheet: CustomerSheet
    @Published var isPaymentsSheetPresented: Bool = false
    
    @Published private(set) var selectedPaymentOption: CustomerSheet.PaymentOptionSelection? = nil
    
    @Published var loadingSections: Set<LoadingSection> = [.retrievePaymentOptionSelection]
    
    init() {
        customerAdapter = StripeCustomerAdapter(customerEphemeralKeyProvider: {
            let data = try await Self.transactionsDM.getCustomerEphemeralKey()
            return CustomerEphemeralKey(customerId: data.customer, ephemeralKeySecret: data.ephemeralKeySecret)
        })
        
        var configuration = CustomerSheet.Configuration()
        
        // Configure settings for the CustomerSheet here. For example:
        configuration.headerTextForSelectionScreen = "Manage your payment methods"
        
        customerSheet = CustomerSheet(configuration: configuration, customer: customerAdapter)

        Task {
            await getPaymentOptionSelection()
        }
    }
    
    func onPaymentMethodCompletion(result: CustomerSheet.CustomerSheetResult) {
        switch result {
        case .canceled(let paymentOptionSelection):
            Task {
                await MainActor.run {
                    selectedPaymentOption = paymentOptionSelection
                }
            }
        case .selected(let paymentOptionSelection):
            Task {
                await MainActor.run {
                    selectedPaymentOption = paymentOptionSelection
                }
            }
        case .error(let error):
            print(error)
        }
    }
    
    @MainActor
    func presentPaymentSheet() {
        self.isPaymentsSheetPresented = true
    }

    private func getPaymentOptionSelection() async {
        await setLoadingState(.retrievePaymentOptionSelection, to: true)
        let paymentOptionSelection = try? await customerAdapter.retrievePaymentOptionSelection()
        await MainActor.run {
            selectedPaymentOption = paymentOptionSelection
        }
        await setLoadingState(.retrievePaymentOptionSelection, to: false)
    }
    
    // MARK: Enums
    
    enum LoadingSection: Hashable {
        case retrievePaymentOptionSelection
    }
}
