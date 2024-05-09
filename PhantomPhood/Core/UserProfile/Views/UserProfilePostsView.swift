//
//  UserProfilePostsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 5/6/24.
//

import SwiftUI

struct UserProfilePostsView: View {
    let user: UserDetail?
    @Binding var activeTab: UserProfileView.UserProfileTab
    
    private let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: 0) {
            ForEach(0...20, id: \.self) { _ in
                Rectangle()
                    .foregroundStyle(Color.themePrimary)
                    .frame(height: 180)
                    .overlay {
                        Rectangle()
                            .stroke(Color.themeBorder, lineWidth: 2)
                    }
            }
        }
    }
}

#Preview {
    UserProfilePostsView(user: nil, activeTab: .constant(.posts))
}
