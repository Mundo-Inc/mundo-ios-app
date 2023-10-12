//
//  CommentsViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/4/23.
//

import Foundation
import Combine

@MainActor
class CommentsViewModel: ObservableObject {
    let apiManager = APIManager()
    let auth: Authentication = Authentication.shared
    
    @Published var currentActivityId: String? = nil
    
    @Published var showComments = false
    @Published var commentContent = ""
    @Published var comments: [Comment] = []
    @Published var isLoading = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        $showComments
            .sink { newValue in
                if !newValue {
                    self.comments.removeAll()
                    self.commentsPage = 1
                    self.currentActivityId = nil
                }
            }
            .store(in: &cancellables)
    }

    var commentsPage = 1

    func getComments(activityId: String) async {
        if isLoading { return }
        struct CommentsResponse: Decodable {
            let success: Bool
            let data: [Comment]
        }
        isLoading = true
        do {
            let (data, _) = try await apiManager.request("/feeds/\(activityId)/comments?page=\(commentsPage)", token: auth.token) as (CommentsResponse?, HTTPURLResponse)
            if let data = data {
                if commentsPage == 1 {
                    comments = data.data
                } else {
                    comments.append(contentsOf: data.data)
                }
                commentsPage += 1
            }
        } catch {
            print(error)
        }
        isLoading = false
    }
    
    func showComments(activityId: String) {
        currentActivityId = activityId
        showComments = true
        Task {
            await getComments(activityId: activityId)
        }
    }
}
