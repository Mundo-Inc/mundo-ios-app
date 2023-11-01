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
            let data = try await apiManager.requestData("/feeds/\(activityId)/comments?page=\(commentsPage)", token: auth.token) as CommentsResponse?
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
            let data = try await apiManager.requestData("/comments", method: .post, body: body, token: token) as ResponseData?
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
    
    enum LikeAction {
        case add
        case remove
    }
    func updateCommentLike(id: String, action: LikeAction) async {
        guard let token = auth.token else { return }
        
        struct ResponseData: Decodable {
            let success: Bool
            let data: Comment
        }
        
        self.isSubmitting = true
        do {
            let data = try await apiManager.requestData("/comments/\(id)/likes", method: action == .add ? .post : .delete, token: token) as ResponseData?
            if let data {
                self.comments = self.comments.map({ comment in
                    return comment.id == data.data.id ? data.data : comment
                })
            } else {
                toastViewModel.toast(.init(type: .error, title: "Error", message: "Something went wrong"))
            }
        } catch {
            toastViewModel.toast(.init(type: .error, title: "Error", message: "Something went wrong"))
        }
        self.isSubmitting = false
    }
}
