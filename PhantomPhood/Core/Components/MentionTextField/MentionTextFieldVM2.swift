//
//  MentionTextFieldVM2.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 5/28/24.
//

import Foundation
import SwiftUI

final class MentionTextFieldVM2: LoadingSections, ObservableObject {
    private let searchDM = SearchDM()
    
    @Published private(set) var suggestions: [UserEssentials] = []
    @Published private(set) var isShowingSuggestions = false
    @Published var loadingSections = Set<LoadingSection>()

    @Binding var text: String
    
    init(text: Binding<String>) {
        self._text = text
    }
    
    private var inQueue: String? = nil
    
    private var cursorPosition: Int? = nil
    private var q: String? = nil
    
    func handleMentionDetection(in textField: UITextView, at cursorPosition: Int) {
        self.cursorPosition = cursorPosition
        let text = textField.text ?? ""
        
        // Ensure the cursor position is within the bounds of the text
        guard cursorPosition <= text.count else {
            return
        }
        
        // Extract the text up to the cursor position
        let cursorIndex = text.index(text.startIndex, offsetBy: cursorPosition)
        
        if cursorPosition + 1 <= text.count {
            if text[cursorIndex].isLetter {
                DispatchQueue.main.async {
                    self.isShowingSuggestions = false
                }
                return
            }
        }
        
        let textUpToCursor = String(text[..<cursorIndex])
        
        if textUpToCursor.last != " " {
            // Scan the text up to the cursor to find an ongoing mention
            let words = textUpToCursor.split(separator: " ")
            if let lastWord = words.last, lastWord.starts(with: "@") {
                // There's an ongoing mention
                let mention = String(lastWord.dropFirst())
                
                self.q = mention
                Task {
                    await updateSuggestions(q: mention)
                }
                DispatchQueue.main.async {
                    self.isShowingSuggestions = true
                }
            } else {
                DispatchQueue.main.async {
                    self.isShowingSuggestions = false
                }
            }
        } else {
            DispatchQueue.main.async {
                self.isShowingSuggestions = false
            }
        }
    }
    
    func onSelect(user: UserEssentials) {
        guard let cursorPosition, let q, cursorPosition <= text.count else {
            return
        }
        
        let newString = replaceWord(in: text, at: cursorPosition, with: q, newWord: user.username)
        
        text = newString.last != " " ? newString + " " : newString
    }
    
    func updateSuggestions(q: String) async {
        guard !loadingSections.contains(.userSearch) else {
            inQueue = q
            return
        }
        
        setLoadingState(.userSearch, to: true)
        do {
            let data = try await searchDM.searchUsers(q: q, limit: 5)
            
            DispatchQueue.main.async {
                self.suggestions = data
            }
        } catch {
            presentErrorToast(error, function: #function)
        }
        setLoadingState(.userSearch, to: false)
        
        if let inQueue, inQueue != q {
            await updateSuggestions(q: inQueue)
        } else {
            inQueue = nil
        }
    }
    
    func replaceWord(in string: String, at cursorIndex: Int, with word: String, newWord: String) -> String {
        // Ensure the cursor index and word length are valid
        guard cursorIndex >= 0 && cursorIndex <= string.count else { return string }
        
        // Create a range for the word to be replaced
        let wordRangeStartIndex = string.index(string.startIndex, offsetBy: cursorIndex - word.count)
        let wordRangeEndIndex = string.index(string.startIndex, offsetBy: cursorIndex)
        let wordRange = wordRangeStartIndex..<wordRangeEndIndex
        
        // Check if the substring matches the word to be replaced
        if string[wordRange] == word {
            // Replace the word
            let newString = string.replacingCharacters(in: wordRange, with: newWord)
            return newString
        }
        
        return string
    }
    
    // MARK: Enums
    
    enum LoadingSection: Hashable {
        case userSearch
    }
}
