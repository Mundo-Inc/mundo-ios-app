//
//  EarningsVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 7/25/24.
//

import Foundation


final class EarningsVM: ObservableObject, SocketListener {
    static let shared = EarningsVM()
    
    private let socketService = SocketService.shared
    
    private init() {
        addSocketListener()
        
        socketService.request(for: .request(event: .earnings))
    }
    
    deinit {
        removeSocketListener()
    }
    
    @Published private(set) var displayChanges: [ChangeEntity] = []
    @Published private(set) var data: EarningData? = nil
    
    func setValue(_ newValue: EarningData) {
        guard let data else {
            self.data = newValue
            return
        }
        
        if newValue.balance != data.balance {
            displayChange(.init(title: newValue.title, amount: newValue.balance - data.balance))
            SoundManager.shared.playSound(.coin)
            if newValue.balance < data.balance {
                HapticManager.shared.impact(style: .light)
            } else {
                HapticManager.shared.impact(style: .medium)
            }
        }
        
        DispatchQueue.main.async {
            self.data = newValue
        }
    }
    
    private func displayChange(_ entity: ChangeEntity) {
        DispatchQueue.main.async {
            self.displayChanges.append(entity)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if let ti = self.displayChanges.first(where: { $0.id == entity.id }) {
                DispatchQueue.main.async {
                    self.displayChanges.removeAll { $0.id == ti.id }
                }
            }
        }
    }
    
    func addSocketListener() {
        socketService.addListener(for: .earnings, id: #file.description) { data, ack in
            guard let first = data.first,
                  let d = first as? [String: Any],
                  let balance = d["balance"] as? Double, let total = d["total"] as? Double else { return }

            self.setValue(EarningData(balance: balance, total: total, title: d["title"] as? String))
        }
    }
    
    func removeSocketListener() {
        socketService.removeListener(for: .earnings, id: #file.description)
    }
    
    // MARK: Structs
    
    struct EarningData: Decodable {
        let balance: Double
        let total: Double
        let title: String?
    }
    
    struct ChangeEntity: Identifiable {
        let id = UUID()
        let title: String?
        let amount: Double
    }
}
