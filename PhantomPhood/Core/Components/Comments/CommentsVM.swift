//
//  CommentsVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/4/23.
//

import Foundation

final class CommentsVM: LoadingSections, ObservableObject {
    private let userActivityDM = UserActivityDM()
    private let commentsDM = CommentsDM()
    
    private let activityId: String
    
    init (activityId: String) {
        self.activityId = activityId
    }
    
    @Published var commentContent = ""
    @Published var comments: [Comment] = []
    @Published var loadingSections = Set<LoadingSection>()
    
    private var commentsPage = 1
    
    func getComments() async {
        guard !loadingSections.contains(.gettingComments) else { return }
        
        setLoadingState(.gettingComments, to: true)
        do {
            let data = try await userActivityDM.getActivityComments(for: activityId, page: commentsPage)
            
            await MainActor.run {
                if commentsPage == 1 {
                    comments = data.data
                } else {
                    comments.append(contentsOf: data.data)
                }
            }
            
            commentsPage += 1
        } catch {
            presentErrorToast(error, function: #function)
        }
        setLoadingState(.gettingComments, to: false)
    }
    
    func submitComment() async {
        guard !loadingSections.contains(.submittingComment) else { return }
        
        setLoadingState(.submittingComment, to: true)
        do {
            let data = try await commentsDM.submitComment(for: activityId, content: commentContent)
            
            await MainActor.run {
                commentContent = ""
                self.comments.insert(data, at: 0)
            }
            
            HapticManager.shared.notification(type: .success)
        } catch {
            presentErrorToast(error, title: "Couldn't add your comment", function: #function)
        }
        setLoadingState(.submittingComment, to: false)
    }
    
    func updateCommentLike(for commentId: String, action: CommentsDM.LikeAction) async {
        guard !loadingSections.contains(.submittingLike(commentId)) else { return }
        
        HapticManager.shared.impact(style: .light)
        
        await MainActor.run {
            self.comments = self.comments.map({ comment in
                if comment.id == commentId {
                    var updatedComment = comment
                    switch action {
                    case .add:
                        updatedComment.liked = true
                        updatedComment.likes += 1
                    case .remove:
                        updatedComment.liked = false
                        updatedComment.likes -= 1
                    }
                    return updatedComment
                }
                return comment
            })
        }
        
        setLoadingState(.submittingLike(commentId), to: true)
        do {
            let data = try await commentsDM.updateCommentLike(for: commentId, action: action)
            
            await MainActor.run {
                self.comments = self.comments.map({ comment in
                    return comment.id == commentId ? data : comment
                })
            }
        } catch {
            HapticManager.shared.impact(style: .heavy)
            await MainActor.run {
                self.comments = self.comments.map({ comment in
                    if comment.id == commentId {
                        var updatedComment = comment
                        switch action {
                        case .add:
                            updatedComment.liked = false
                            updatedComment.likes -= 1
                        case .remove:
                            updatedComment.liked = true
                            updatedComment.likes += 1
                        }
                        return updatedComment
                    }
                    return comment
                })
            }
            presentErrorToast(error, function: #function)
        }
        setLoadingState(.submittingLike(commentId), to: false)
    }
    
    // MARK: Enums
    
    enum LoadingSection: Hashable {
        case gettingComments
        case submittingComment
        case submittingLike(String)
    }
}
