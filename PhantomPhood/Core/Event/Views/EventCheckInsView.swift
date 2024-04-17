//
//  EventCheckInsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/9/24.
//

import SwiftUI

struct EventCheckInsView: View {
    @StateObject private var vm: EventCheckInsVM
    @ObservedObject private var eventVM: EventVM
    
    init(eventVM: EventVM) {
        self._vm = StateObject(wrappedValue: EventCheckInsVM(eventVM: eventVM))
        self._eventVM = ObservedObject(wrappedValue: eventVM)
    }
    
    var body: some View {
        LazyVStack {
            if let checkIns = vm.checkIns {
                if checkIns.isEmpty {
                    Text("No Check-ins Yet!")
                        .font(.custom(style: .subheadline))
                        .foregroundStyle(.secondary)
                        .padding(.vertical)
                        .padding(.horizontal)
                } else {
                    ForEach(checkIns) { checkIn in
                        HStack {
                            ProfileImage(checkIn.user.profileImage, size: 50, cornerRadius: 25)
                            
                            Text(checkIn.user.name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fontWeight(.semibold)
                            
                            Text(checkIn.createdAt.timeElapsed(suffix: " ago"))
                                .font(.custom(style: .caption2))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        Divider()
                    }
                    
                    Color.clear
                        .frame(width: 0, height: 0)
                        .task {
                            await vm.fetch(type: .new)
                        }
                }
            } else {
                ProgressView()
                    .padding(.top)
                    .task {
                        await vm.fetch(type: .new)
                    }
            }
            
            Spacer()
        }
    }
}
