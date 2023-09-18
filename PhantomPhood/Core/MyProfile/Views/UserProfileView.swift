//
//  UserProfileView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject private var appData: AppData
    
    var body: some View {
        NavigationStack(path: $appData.userProfileNavStack) {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
