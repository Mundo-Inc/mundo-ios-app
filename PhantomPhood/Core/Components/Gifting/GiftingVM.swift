//
//  GiftingVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/30/24.
//

import Foundation
import StripePaymentSheet

final class GiftingVM: LoadingSections, ObservableObject {
    static let defaultOptions: [Double] = [10.0, 20.0, 50.0, 100.0]
    
    static private let transactionsDM = TransactionsDM()
    private let userProfileDM = UserProfileDM()
    
    @Published var loadingSections = Set<LoadingSection>()
    
    @Published private(set) var user: UserEssentials?
    
    @Published var selectionIndex: Int = 0
    @Published var customAmount: String = ""
    @Published var message: String = ""
    
    private(set) var customerAdapter: StripeCustomerAdapter
    private(set) var customerSheet: CustomerSheet
    @Published var isPaymentsSheetPresented: Bool = false
    
    @Published private(set) var selectedPaymentOption: CustomerSheet.PaymentOptionSelection? = nil
    
    init(user: UserEssentials) {
        self.user = user
        
        customerAdapter = StripeCustomerAdapter(customerEphemeralKeyProvider: {
            do {
                let data = try await Self.transactionsDM.getCustomerEphemeralKey()
                return CustomerEphemeralKey(customerId: data.customer, ephemeralKeySecret: data.ephemeralKeySecret)
            } catch {
                presentErrorToast(error)
                throw error
            }
            
        })
        
        var configuration = CustomerSheet.Configuration()
        
        // Configure settings for the CustomerSheet here. For example:
        configuration.headerTextForSelectionScreen = "Manage your payment methods"
        
        customerSheet = CustomerSheet(configuration: configuration, customer: customerAdapter)

        Task {
            await getPaymentOptionSelection()
        }
    }
    
    init(userId: String) {
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
        Task {
            await getUserInfo(byId: userId)
        }
    }
    
    var giftAmount: Double? {
        if customAmount.isEmpty {
            return Self.defaultOptions[selectionIndex]
        } else if let amount = Double(customAmount) {
            return amount
        }
        
        return nil
    }
    
    func submit(callback: @escaping (Bool) -> Void = { _ in }) async {
        guard let user, let selectedPaymentOption, let giftAmount, !loadingSections.contains(.submitting) else { return }
        
        setLoadingState(.submitting, to: true)
        do {
            if case .paymentMethod(let paymentMethod, _) = selectedPaymentOption {
                try await Self.transactionsDM.sendGift(amount: giftAmount, to: user.id, using: paymentMethod.stripeId, message: message)
                callback(true)
                HapticManager.shared.notification(type: .success)
                ToastVM.shared.toast(.init(type: .success, title: "Successful", message: "You have successfully gifted \(user.name) $\(giftAmount.formatted())"))
            } else {
                callback(false)
                HapticManager.shared.notification(type: .warning)
                ToastVM.shared.toast(.init(type: .error, title: "Not Supported", message: "Selected payment method is not supported yet"))
            }
        } catch {
            callback(false)
            presentErrorToast(error, function: #function)
        }
        setLoadingState(.submitting, to: false)
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
        setLoadingState(.retrievePaymentOptionSelection, to: true)
        do {
            let paymentOptionSelection = try await customerAdapter.retrievePaymentOptionSelection()
            await MainActor.run {
                selectedPaymentOption = paymentOptionSelection
            }
        } catch {
            presentErrorToast(error, function: #function)
        }
        setLoadingState(.retrievePaymentOptionSelection, to: false)
    }
    
    private func getUserInfo(byId userId: String) async {
        guard !loadingSections.contains(.fetchingUser) else { return }
        
        setLoadingState(.fetchingUser, to: true)
        do {
            let data = try await userProfileDM.getUserEssentials(id: userId)
            
            await MainActor.run {
                self.user = data
            }
        } catch {
            presentErrorToast(error, function: #function)
        }
        setLoadingState(.fetchingUser, to: false)
    }
}

extension GiftingVM {
    enum LoadingSection: Hashable {
        case fetchingUser
        case submitting
        case retrievePaymentOptionSelection
    }
}
