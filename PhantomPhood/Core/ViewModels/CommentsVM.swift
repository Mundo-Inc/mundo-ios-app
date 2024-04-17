//
//  CommentsViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/4/23.
//

import Foundation

@MainActor
final class CommentsVM: ObservableObject {
    static let shared = CommentsVM()
    
    private let auth = Authentication.shared
    private let apiManager = APIManager.shared
    private let toastVM = ToastVM.shared
    
    @Published var currentActivityId: String? = nil
    
    @Published var commentContent = ""
    @Published var comments: [Comment] = []
    @Published var isLoading = false
    @Published var isSubmitting = false
    
    private init() {}
    
    /// Reset comments when the comments view is dismissed
    func onDismiss() {
        self.comments.removeAll()
        self.commentsPage = 1
    }
    
    var commentsPage = 1
    
    func getComments(activityId: String) async {
        guard !isLoading, let token = await auth.getToken() else { return }
        
        isLoading = true
        do {
            let data: APIResponse<[Comment]> = try await apiManager.requestData("/feeds/\(activityId)/comments?page=\(commentsPage)", token: token)
            if commentsPage == 1 {
                comments = data.data
            } else {
                comments.append(contentsOf: data.data)
            }
            commentsPage += 1
        } catch {
            presentErrorToast(error)
        }
        isLoading = false
    }
    
    func showComments(activityId: String) {
        currentActivityId = activityId
        Task {
            await getComments(activityId: activityId)
        }
    }
    
    func submitComment() async {
        guard
            let activityID = self.currentActivityId,
            let token = await auth.getToken(),
            !activityID.isEmpty && !self.isSubmitting
        else { return }
        
        struct RequestBody: Encodable {
            let content: String
            let activity: String
        }
        
        self.isSubmitting = true
        do {
            let body = try apiManager.createRequestBody(RequestBody(content: commentContent, activity: activityID))
            let data: APIResponse<Comment> = try await apiManager.requestData("/comments", method: .post, body: body, token: token)
            commentContent = ""
            self.comments.insert(data.data, at: 0)
            toastVM.toast(.init(type: .success, title: "Success", message: "Comment Added"))
        } catch {
            presentErrorToast(error, title: "Couldn't add your comment")
        }
        self.isSubmitting = false
    }
    
    func updateCommentLike(id: String, action: LikeAction) async {
        guard let token = await auth.getToken() else { return }
        
        self.isSubmitting = true
        do {
            let data: APIResponse<Comment> = try await apiManager.requestData("/comments/\(id)/likes", method: action == .add ? .post : .delete, token: token)
            self.comments = self.comments.map({ comment in
                return comment.id == data.data.id ? data.data : comment
            })
        } catch {
            presentErrorToast(error)
        }
        self.isSubmitting = false
    }
    
    // MARK: Enums
    
    enum LikeAction {
        case add
        case remove
    }
}
