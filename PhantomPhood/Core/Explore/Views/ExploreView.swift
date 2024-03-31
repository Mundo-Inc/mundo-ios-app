//
//  ExploreView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/17/24.
//

import SwiftUI

struct ExploreView: View {
    @StateObject private var exploreSearchVM = ExploreSearchVM()
    
    var body: some View {
        Group {
            if #available(iOS 17.0, *) {
                ExploreView17()
            } else {
                ExploreView16()
            }
        }
        .toolbarBackground(Color.themePrimary, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .environmentObject(exploreSearchVM)
    }
}

#Preview {
    ExploreView()
}
