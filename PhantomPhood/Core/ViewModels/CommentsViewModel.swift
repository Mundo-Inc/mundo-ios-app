//
//  CommentsViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/4/23.
//

import Foundation

@MainActor
class CommentsViewModel: ObservableObject {
    let activityId: String
    
    init(activityId: String) {
        self.activityId = activityId
    }
    
    let apiManager = APIManager()
    let auth: Authentication = Authentication.shared
    
    @Published var showComments = false
    @Published var commentContent = ""
    @Published var comments: [Comment] = []
    @Published var isLoading = false

    var commentsPage = 1

    func getComments() async {
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
}
