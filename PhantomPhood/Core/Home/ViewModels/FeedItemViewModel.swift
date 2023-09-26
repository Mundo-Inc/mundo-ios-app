//
//  FeedItemViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 22.09.2023.
//

import Foundation

@MainActor
class FeedItemViewModel: ObservableObject {
    let apiManager = APIManager()
    let auth: Authentication = Authentication.shared
    
    @Published var showComments = false
    @Published var commentContent = ""
    @Published var comments: [Comment] = []
    @Published var commentsLoading = false

    var commentsPage = 1

    func getComments(id: String) async {
        if commentsLoading { return }
        struct CommentsResponse: Decodable {
            let success: Bool
            let data: [Comment]
        }
        commentsLoading = true
        do {
            print(commentsPage)
            let (data, _) = try await apiManager.request("/feeds/\(id)/comments?page=\(commentsPage)", token: auth.token) as (CommentsResponse?, HTTPURLResponse)
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
        commentsLoading = false
    }
}
