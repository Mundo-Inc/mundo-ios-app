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
    private let apiManager = APIManager()
    private let auth: Authentication = Authentication.shared
    private let toastViewModel = ToastViewModel.shared
    
    @Published var currentActivityId: String? = nil
    
    @Published var showComments = false
    @Published var commentContent = ""
    @Published var comments: [Comment] = []
    @Published var isLoading = false
    @Published var isSubmitting = false
    
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
    
    func submitComment() async {
        guard
            let activityID = self.currentActivityId,
            let token = auth.token,
            !activityID.isEmpty && self.showComments && !self.isSubmitting
        else { return }
        
        
        struct RequestBody: Encodable {
            let content: String
            let activity: String
        }
        struct ResponseData: Decodable {
            let success: Bool
            let data: Comment
        }
        
        self.isSubmitting = true
        do {
            let body = try apiManager.createRequestBody(RequestBody(content: commentContent, activity: activityID))
            let (data, _) = try await apiManager.request("/comments", method: .post, body: body, token: token) as (ResponseData?, HTTPURLResponse)
            commentContent = ""
            if let data {
                self.comments.insert(data.data, at: 0)
                toastViewModel.toast(.init(type: .success, title: "Success", message: "Comment Added"))
            } else {
                toastViewModel.toast(.init(type: .error, title: "Error", message: "We couldn't add your comment"))
            }
        } catch {
            toastViewModel.toast(.init(type: .error, title: "Error", message: "Something went wrong"))
        }
        self.isSubmitting = false
    }
    
    // TODO: Add like/dislike comment
//    func likeComment(commentID: String) async {
//
//    }
}
