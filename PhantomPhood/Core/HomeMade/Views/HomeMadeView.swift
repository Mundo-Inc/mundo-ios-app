//
//  HomeMadeView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/12/24.
//

import SwiftUI

struct HomeMadeView: View {
    @StateObject private var vm = HomeMadeVM()
    @StateObject private var pickerVM = PickerVM()
    
    var body: some View {
        ZStack {
            
        }
        .navigationTitle("Homemade Experience")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HomeMadeView()
    }
}
