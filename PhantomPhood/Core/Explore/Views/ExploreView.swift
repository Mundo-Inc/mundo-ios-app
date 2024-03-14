//
//  ExploreView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/17/24.
//

import SwiftUI

struct ExploreView: View {
    @ObservedObject private var appData = AppData.shared
    @StateObject private var exploreSearchVM = ExploreSearchVM()
    
    var body: some View {
        if #available(iOS 17.0, *) {
            NavigationStack(path: $appData.exploreNavStack) {
                ExploreView17()
                    .ignoresSafeArea(.keyboard)
                    .toolbarBackground(Color.themePrimary, for: .navigationBar)
                    .navigationTitle("Explore")
                    .navigationBarTitleDisplayMode(.inline)
                    .handleNavigationDestination()
                    .padding(.bottom, 50)
            }
            .searchable(text: $exploreSearchVM.text, placement: .navigationBarDrawer(displayMode: .always))
            .searchScopes($exploreSearchVM.scope, activation: SearchScopeActivation.onSearchPresentation) {
                Text(SearchScopes.places.title)
                    .tag(SearchScopes.places)
                
                Text(SearchScopes.users.title)
                    .tag(SearchScopes.users)
            }
            .environmentObject(exploreSearchVM)
        } else if #available(iOS 16.4, *) {
            NavigationStack(path: $appData.exploreNavStack) {
                ExploreView16()
                    .ignoresSafeArea(.keyboard)
                    .toolbarBackground(Color.themePrimary, for: .navigationBar)
                    .navigationTitle("Explore")
                    .navigationBarTitleDisplayMode(.inline)
                    .handleNavigationDestination()
                    .padding(.bottom, 50)
            }
            .searchable(text: $exploreSearchVM.text, placement: .navigationBarDrawer(displayMode: .always))
            .searchScopes($exploreSearchVM.scope, activation: SearchScopeActivation.onSearchPresentation) {
                Text(SearchScopes.places.title)
                    .tag(SearchScopes.places)
                
                Text(SearchScopes.users.title)
                    .tag(SearchScopes.users)
            }
            .environmentObject(exploreSearchVM)
        } else {
            NavigationStack(path: $appData.exploreNavStack) {
                ExploreView16()
                    .ignoresSafeArea(.keyboard)
                    .toolbarBackground(Color.themePrimary, for: .navigationBar)
                    .navigationTitle("Explore")
                    .navigationBarTitleDisplayMode(.inline)
                    .handleNavigationDestination()
                    .padding(.bottom, 50)
            }
            .searchable(text: $exploreSearchVM.text, placement: .navigationBarDrawer(displayMode: .always))
            .searchScopes($exploreSearchVM.scope) {
                Text(SearchScopes.places.title)
                    .tag(SearchScopes.places)
                
                Text(SearchScopes.users.title)
                    .tag(SearchScopes.users)
            }
            .environmentObject(exploreSearchVM)
        }
    }
}

#Preview {
    ExploreView()
}
