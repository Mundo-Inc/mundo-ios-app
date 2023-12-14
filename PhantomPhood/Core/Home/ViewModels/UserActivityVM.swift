//
//  UserActivityVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/14/23.
//

import Foundation

@MainActor
final class UserActivityVM: ObservableObject {
    private let userActivityDM = UserActivityDM()
    
    @Published private(set) var activity: FeedItem? = nil
    @Published private(set) var isLoading: Bool = false
    @Published var error: String? = nil
    
    func getActivity(_ id: String) async {
        self.isLoading = true
        do {
            let data = try await userActivityDM.getUserActivity(id)
            self.activity = data
        } catch {
            self.error = error.localizedDescription
            print(error)
        }
        self.isLoading = false
    }
}
