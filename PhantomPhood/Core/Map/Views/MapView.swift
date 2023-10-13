//
//  MapView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject private var appData: AppData
    @StateObject private var vm = MapViewModel()
    
    var body: some View {
        NavigationStack(path: $appData.mapNavStack) {
            ZStack {
                if #available(iOS 17.0, *) {
                    MapView17(vm: vm)
                } else {
                    MapView16(vm: vm)
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if vm.isLoading {
                        ProgressView()
                    }
                }
            })
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
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
