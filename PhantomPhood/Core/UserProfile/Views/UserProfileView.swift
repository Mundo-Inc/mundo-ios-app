//
//  UserProfileView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import SwiftUI

struct UserProfileView: View {
    let id: String
    
    var body: some View {
        VStack {
            Text("Hello, World!")
            Text(id)
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(id: "TEST_ID")
    }
}
