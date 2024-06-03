//
//  CommentsVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/4/23.
//

import Foundation
import SwiftUI

final class CommentsVM: LoadingSections, ObservableObject {
    static let commentsPageLimit = 30
    
    private let userActivityDM = UserActivityDM()
    private let commentsDM = CommentsDM()
    
    private let activityId: String
    
    init (activityId: String) {
        self.activityId = activityId
    }
    
    @Published var loadingSections = Set<LoadingSection>()
    
    @Published var commentContent = ""
    @Published var replyTo: Comment? = nil
    
    @Published var comments: [Comment] = []
    
    @Published var repliesDict = [String: Comment]()
    
    private var commentsPagination: Pagination? = nil
    
    func getComments(_ action: RefreshNewAction) async {
        guard !loadingSections.contains(.gettingComments) else { return }
        
        if action == .refresh {
            commentsPagination = nil
        } else if let commentsPagination, !commentsPagination.hasMore {
            return
        }
        
        setLoadingState(.gettingComments, to: true)
        do {
            let page = if let commentsPagination {
                commentsPagination.page + 1
            } else {
                1
            }
            
            let data = try await userActivityDM.getActivityComments(for: activityId, page: page, limit: Self.commentsPageLimit)
            
            await MainActor.run {
                if action == .refresh || comments.isEmpty {
                    comments = data.data.comments
                    repliesDict = Dictionary(uniqueKeysWithValues: data.data.replies.map { ($0.id, $0) })
                } else {
                    for cm in data.data.comments {
                        comments.append(cm)
                    }
                    for cm in data.data.replies {
                        repliesDict.updateValue(cm, forKey: cm.id)
                    }
                }
            }
            
            commentsPagination = data.pagination
        } catch {
            presentErrorToast(error)
        }
        setLoadingState(.gettingComments, to: false)
    }
    
    func submitComment() async {
        guard !loadingSections.contains(.submittingComment) else { return }
        
        setLoadingState(.submittingComment, to: true)
        do {
            let data = try await commentsDM.submitComment(for: activityId, content: commentContent, parent: replyTo?.id)
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                self.repliesDict.updateValue(data, forKey: data.id)
                if let parentId = self.replyTo?.id {
                    if let parentIndex = self.comments.firstIndex(where: { $0.id == parentId }) {
                        self.comments[parentIndex].addReply(data.id)
                    } else if self.repliesDict[parentId] != nil {
                        self.repliesDict[parentId]!.addReply(data.id)
                    }
                } else {
                    self.comments.insert(data, at: 0)
                }
                
                self.commentContent = ""
                self.replyTo = nil
            }
            
            HapticManager.shared.notification(type: .success)
        } catch {
            presentErrorToast(error, title: "Couldn't add your comment")
        }
        setLoadingState(.submittingComment, to: false)
    }
    
    func updateCommentLike(for commentId: String, action: CommentsDM.LikeAction) async {
        guard !loadingSections.contains(.submittingLike(commentId)) else { return }
        
        HapticManager.shared.impact(style: .light)
        
        await MainActor.run {
            if repliesDict[commentId] != nil {
                repliesDict[commentId]!.setLike(to: action == .add)
            } else if let index = comments.firstIndex(where: { $0.id == commentId }) {
                self.comments[index].setLike(to: action == .add)
            }
        }
        
        setLoadingState(.submittingLike(commentId), to: true)
        do {
            let data = try await commentsDM.updateCommentLike(for: commentId, action: action)
            
            await MainActor.run {
                if repliesDict[commentId] != nil {
                    repliesDict[commentId]!.liked = data.liked
                    repliesDict[commentId]!.likes = data.likes
                } else if let index = self.comments.firstIndex(where: { $0.id == commentId }) {
                    self.comments[index].liked = data.liked
                    self.comments[index].likes = data.likes
                }
            }
        } catch {
            HapticManager.shared.impact(style: .heavy)
            
            await MainActor.run {
                if repliesDict[commentId] != nil {
                    repliesDict[commentId]!.setLike(to: action == .remove)
                } else if let index = self.comments.firstIndex(where: { $0.id == commentId }) {
                    self.comments[index].setLike(to: action == .remove)
                }
            }
            presentErrorToast(error)
        }
        setLoadingState(.submittingLike(commentId), to: false)
    }
    
    func getComment(_ comment: Comment, _ depth: [String]?) -> Comment {
        var cm = comment
        if let depth {
            if let last = depth.last, let reply = repliesDict[last] {
                cm = reply
            }
        }
        return cm
    }
    
    @MainActor
    func populateReplies(_ comment: Comment) async {
        guard let repliesCount = comment.repliesCount,
              repliesCount > 0,
              repliesCount > (comment.replies?.count ?? 0) else { return }
        
        do {
            let page = if let replies = comment.replies {
                Int(floor(Double(replies.count) / Double(Self.commentsPageLimit))) + 1
            } else {
                1
            }
            
            let data = try await commentsDM.getReplies(for: comment.id, page: page, limit: Self.commentsPageLimit)
            
            for item in data {
                repliesDict.updateValue(item, forKey: item.id)
            }
            
            if let cm = repliesDict[comment.id] {
                // In replies
                
                // Update reply ids
                var newComment = cm
                if let replies = newComment.replies {
                    for item in data {
                        if !replies.contains(where: { $0 == item.id }) {
                            newComment.replies!.append(item.id)
                        }
                    }
                } else {
                    newComment.replies = data.map({ $0.id })
                }
                repliesDict.updateValue(newComment, forKey: comment.id)
            } else if let cmIndex = comments.firstIndex(where: { $0.id == comment.id }) {
                // In root comments
                
                var newComment = comments[cmIndex]
                if let replies = newComment.replies {
                    for item in data {
                        if !replies.contains(where: { $0 == item.id }) {
                            newComment.replies!.append(item.id)
                        }
                    }
                } else {
                    newComment.replies = data.map({ $0.id })
                }
                comments[cmIndex] = newComment
            }
        } catch {
            print(error)
        }
    }
    
    // MARK: Enums
    
    enum LoadingSection: Hashable {
        case gettingComments
        case submittingComment
        case submittingLike(String)
    }
}
