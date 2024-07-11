//
//  UserProfileCheckInsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 6/12/24.
//

import SwiftUI

struct UserProfileCheckInsView: View {
    @StateObject private var vm: ProfileCheckinsVM
    private let userId: UserIdEnum
    
    init(_ userIdEnum: UserIdEnum) {
        self.userId = userIdEnum
        self._vm = StateObject(wrappedValue: ProfileCheckinsVM(userId: userIdEnum))
    }
    
    var body: some View {
        if let checkIns = vm.checkIns {
            LazyVStack {
                VStack(spacing: 0) {
                    HStack {
                        if let total = vm.total {
                            Text(total > 1 ? "\(total) Check-Ins" : total == 0 ? "No Check-Ins" : "1 Check-In")
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        NavigationLink(value: AppRoute.userCheckins(userId: userId)) {
                            Label("View on Map", systemImage: "map")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .cfont(.caption)
                    .fontWeight(.medium)
                    .padding()
                    
                    Divider()
                }
                
                ForEach(checkIns) { item in
                    NavigationLink(value: AppRoute.place(id: item.place.id)) {
                        VStack(spacing: 10) {
                            HStack {
                                Text(item.place.name)
                                    .cfont(.subheadline)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                
                                Text(DateFormatter.dateToShortString(date: item.createdAt))
                                    .cfont(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            VStack(spacing: 2) {
                                Group {
                                    if let country = item.place.location.country, !country.isEmpty {
                                        if let city = item.place.location.city, !city.isEmpty {
                                            Text("\(country) | \(city)")
                                        } else {
                                            if let state = item.place.location.state, !state.isEmpty {
                                                Text("\(country) | \(state)")
                                            } else {
                                                Text(country)
                                            }
                                        }
                                    }
                                    if let address = item.place.location.address, !address.isEmpty {
                                        Text(address)
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .cfont(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                    .padding()
                    
                    Divider()
                }
            }
        } else {
            ZStack {
                Color.themeBG
                
                ProgressView()
            }
        }
    }
}

#Preview {
    UserProfileCheckInsView(.currentUser)
}
