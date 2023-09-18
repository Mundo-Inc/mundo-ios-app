//
//  MapView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import SwiftUI

struct MapView: View {
    @EnvironmentObject private var appData: AppData
    
    var body: some View {
        NavigationStack(path: $appData.mapNavStack) {
            ScrollView {
                VStack {
                    Text("Map")
                }
            }
            .navigationTitle("Map")
            .navigationDestination(for: MapStack.self) { link in
                switch link {
                case .place(let id):
                    PlaceView(id: id)
                case .userProfile(let id):
                    UserProfileView(id: id)
                }
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(AppData())
    }
}
