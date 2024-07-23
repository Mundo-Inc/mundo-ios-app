//
//  MapActivitySheet.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/28/24.
//

import SwiftUI

struct MapActivitySheet: View {
    private let clusteredMapActivity: ClusteredMapActivity
    
    @StateObject private var vm = MapActivitySheetVM()
    
    @Environment(\.dismiss) private var dismiss
    
    init(_ clusteredMapActivity: ClusteredMapActivity) {
        self.clusteredMapActivity = clusteredMapActivity
    }
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack(spacing: -15) {
                    ForEach(clusteredMapActivity.items.indices, id: \.self) { index in
                        HStack {
                            ProfileImage(clusteredMapActivity.items[index].user.profileImage, size: 50, cornerRadius: 10)
                                .opacity(vm.show ? (index == vm.selection ? 1 : 0.4) : 0)
                                .rotationEffect(vm.show ? .zero : .degrees(-15))
                                .offset(x: vm.show ? 0 : -Double(index) * 20.0)
                                .animation(.bouncy(duration: 0.6).delay(min(0.1 * Double(index), 1)), value: vm.show)
                                .onTapGesture {
                                    if vm.selection == index {
                                        AppData.shared.goToUser(clusteredMapActivity.items[index].user.id)
                                        dismiss()
                                    } else {
                                        withAnimation {
                                            vm.selection = index
                                        }
                                    }
                                }
                            
                            if vm.selection == index {
                                VStack(alignment: .leading) {
                                    Text(clusteredMapActivity.items[index].user.name)
                                    
                                    Text("@\(clusteredMapActivity.items[index].user.username)")
                                        .cfont(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.trailing, 15)
                                .onTapGesture {
                                    AppData.shared.goToUser(clusteredMapActivity.items[index].user.id)
                                    dismiss()
                                }
                            }
                        }
                        .background(RoundedRectangle(cornerRadius: 10).foregroundStyle(Color.themePrimary))
                        .padding(.trailing, index == vm.selection ? 25 : 0)
                        .animation(.bouncy, value: vm.selection)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            .padding(.top)
            
            HStack {
                if clusteredMapActivity.items.count >= vm.selection + 1 && Authentication.shared.currentUser?.id != clusteredMapActivity.items[vm.selection].user.id {
                    Button {
                        Task {
                            await vm.startConversation(with: clusteredMapActivity.items[vm.selection].user.id)
                            dismiss()
                        }
                    } label: {
                        HStack {
                            if vm.loadingSections.contains(.startingConversation) {
                                ProgressView()
                                    .controlSize(.mini)
                            } else {
                                Text("Say Hi to **\(clusteredMapActivity.items[vm.selection].user.name)** 👋")
                            }
                        }
                        .frame(height: 28)
                        .padding(.horizontal, 8)
                        .background(Color.themeBorder)
                        .clipShape(.rect(cornerRadius: 5))
                        .foregroundStyle(Color.primary)
                    }
                } else {
                    Text("Hi **Me** 👋")
                        .frame(height: 28)
                        .padding(.horizontal, 8)
                        .background(Color.themeBorder)
                        .clipShape(.rect(cornerRadius: 5))
                        .foregroundStyle(Color.primary)
                }
                
                
                Spacer()
            }
            .padding(.horizontal)
            .cfont(.footnote)
            
            Spacer()
            
            if let first = clusteredMapActivity.first {
                VStack(alignment: .leading) {
                    HStack {
                        Text(first.place.name)
                            .cfont(.title2)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "chevron.forward")
                    }
                    
                    if let address = first.place.location.address {
                        Text(address)
                            .foregroundStyle(.secondary)
                            .cfont(.caption)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    AppData.shared.goTo(.place(id: first.place.id))
                    dismiss()
                }
                .padding(.horizontal)
            }
            
            TabView(selection: $vm.selection) {
                ForEach(clusteredMapActivity.items.indices, id: \.self) { index in
                    VStack {
                        if let activity = vm.feedItems[clusteredMapActivity.items[index].id] {
                            ScrollView {
                                VStack {
                                    switch activity.resource {
                                    case .checkin(let checkin):
                                        Label {
                                            HStack {
                                                Text("\(checkin.user.name) checked-in here")
                                                
                                                Spacer()
                                                
                                                Text(checkin.createdAt.timeElapsed(suffix: " ago"))
                                                    .cfont(.caption)
                                                    .foregroundStyle(.tertiary)
                                                    .fontWeight(.regular)
                                            }
                                        } icon: {
                                            Image(systemName: "mappin.and.ellipse")
                                                .foregroundStyle(LinearGradient(colors: [Color.green, Color.accentColor], startPoint: .topLeading, endPoint: .trailing))
                                        }
                                        .foregroundStyle(.primary)
                                        .cfont(.subheadline)
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        if let caption = checkin.caption, !caption.isEmpty {
                                            Label {
                                                Text("Note")
                                            } icon: {
                                                Image(systemName: "pencil")
                                            }
                                            .foregroundStyle(.tertiary)
                                            .cfont(.subheadline)
                                            .fontWeight(.semibold)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.top)
                                            .padding(.bottom, 3)
                                            
                                            Text(caption)
                                                .multilineTextAlignment(.leading)
                                                .lineLimit(8)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .foregroundStyle(.primary)
                                                .cfont(.caption)
                                        }
                                        
                                        if let tags = checkin.tags {
                                            VStack(spacing: 5) {
                                                ForEach(tags) { user in
                                                    TaggedUser(user)
                                                }
                                            }
                                            .padding(.top)
                                        }
                                        
                                        if let media = checkin.media, !media.isEmpty {
                                            Label {
                                                Text("Media")
                                            } icon: {
                                                Image(systemName: "photo.on.rectangle")
                                            }
                                            .foregroundStyle(.tertiary)
                                            .cfont(.subheadline)
                                            .fontWeight(.semibold)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.top)
                                            .padding(.bottom, 3)
                                            
                                            ScrollView(.horizontal) {
                                                HStack {
                                                    ForEach(media) { item in
                                                        switch item.type {
                                                        case .video:
                                                            ImageLoader(item.thumbnail) { _ in
                                                                Image(systemName: "arrow.down.circle.dotted")
                                                                    .foregroundStyle(Color.white.opacity(0.5))
                                                            }
                                                            .frame(width: 100, height: 100)
                                                            .overlay {
                                                                ZStack {
                                                                    Color.black.opacity(0.5)
                                                                    
                                                                    Image(systemName: "video.fill")
                                                                        .font(.system(size: 24))
                                                                        .foregroundStyle(Color.white.opacity(0.8))
                                                                }
                                                            }
                                                            .clipShape(.rect(cornerRadius: 8))
                                                        case .image:
                                                            ImageLoader(item.src) { _ in
                                                                Image(systemName: "arrow.down.circle.dotted")
                                                                    .foregroundStyle(Color.white.opacity(0.5))
                                                            }
                                                            .frame(width: 100, height: 100)
                                                            .clipShape(.rect(cornerRadius: 8))
                                                        }
                                                    }
                                                }
                                            }
                                            .scrollIndicators(.never)
                                        }
                                    case .review(let review):
                                        Label {
                                            HStack {
                                                Text("\(review.writer.name) reviewed this place")
                                                
                                                Spacer()
                                                
                                                Text(review.createdAt.timeElapsed(suffix: " ago"))
                                                    .cfont(.caption)
                                                    .foregroundStyle(.tertiary)
                                                    .fontWeight(.regular)
                                            }
                                        } icon: {
                                            Image(systemName: "ellipsis.message")
                                                .foregroundStyle(LinearGradient(colors: [Color.green, Color.accentColor], startPoint: .topLeading, endPoint: .trailing))
                                        }
                                        .foregroundStyle(.primary)
                                        .cfont(.subheadline)
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        if !review.content.isEmpty {
                                            Label {
                                                HStack {
                                                    Text("Review")
                                                    
                                                    Spacer()
                                                    
                                                    if let recommend = review.recommend {
                                                        Image(systemName: recommend ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
                                                            .foregroundStyle(recommend ? .green : .red)
                                                    }
                                                }
                                            } icon: {
                                                Image(systemName: "pencil")
                                            }
                                            .foregroundStyle(.tertiary)
                                            .cfont(.subheadline)
                                            .fontWeight(.semibold)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.top)
                                            .padding(.bottom, 3)
                                            
                                            Text(review.content)
                                                .multilineTextAlignment(.leading)
                                                .lineLimit(8)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .foregroundStyle(.primary)
                                                .cfont(.caption)
                                            
                                            if let tags = review.tags, !tags.isEmpty {
                                                ScrollView(.horizontal) {
                                                    HStack {
                                                        ForEach(tags, id: \.self) { tag in
                                                            Text("#" + tag)
                                                        }
                                                    }
                                                }
                                                .scrollIndicators(.never)
                                                .cfont(.caption)
                                                .foregroundStyle(.secondary)
                                            }
                                        }
                                        
                                        if let media = review.media, !media.isEmpty {
                                            Label {
                                                Text("Media")
                                            } icon: {
                                                Image(systemName: "photo.on.rectangle")
                                            }
                                            .foregroundStyle(.tertiary)
                                            .cfont(.subheadline)
                                            .fontWeight(.semibold)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.top)
                                            .padding(.bottom, 3)
                                            
                                            ScrollView(.horizontal) {
                                                HStack {
                                                    ForEach(media) { item in
                                                        switch item.type {
                                                        case .video:
                                                            ImageLoader(item.thumbnail) { _ in
                                                                Image(systemName: "arrow.down.circle.dotted")
                                                                    .foregroundStyle(Color.white.opacity(0.5))
                                                            }
                                                            .frame(width: 100, height: 100)
                                                            .overlay {
                                                                ZStack {
                                                                    Color.black.opacity(0.5)
                                                                    
                                                                    Image(systemName: "video.fill")
                                                                        .font(.system(size: 24))
                                                                        .foregroundStyle(Color.white.opacity(0.8))
                                                                }
                                                            }
                                                            .clipShape(.rect(cornerRadius: 8))
                                                        case .image:
                                                            ImageLoader(item.src) { _ in
                                                                Image(systemName: "arrow.down.circle.dotted")
                                                                    .foregroundStyle(Color.white.opacity(0.5))
                                                            }
                                                            .frame(width: 100, height: 100)
                                                            .clipShape(.rect(cornerRadius: 8))
                                                        }
                                                    }
                                                }
                                            }
                                            .scrollIndicators(.never)
                                        }
                                        
                                        if review.scores.overall != nil || review.scores.atmosphere != nil || review.scores.drinkQuality != nil || review.scores.foodQuality != nil || review.scores.service != nil || review.scores.value != nil {
                                            Label {
                                                Text("Scores")
                                            } icon: {
                                                Image(systemName: "star")
                                            }
                                            .foregroundStyle(.tertiary)
                                            .cfont(.subheadline)
                                            .fontWeight(.semibold)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.top)
                                            .padding(.bottom, 3)
                                            
                                            VStack(spacing: 8) {
                                                if let score = review.scores.overall {
                                                    ScoreItem(title: "Overall Score", score: score)
                                                }
                                                if let score = review.scores.drinkQuality {
                                                    ScoreItem(title: "Drink Quality", score: score)
                                                }
                                                if let score = review.scores.foodQuality {
                                                    ScoreItem(title: "Food Quality", score: score)
                                                }
                                                if let score = review.scores.service {
                                                    ScoreItem(title: "Service", score: score)
                                                }
                                                if let score = review.scores.atmosphere {
                                                    ScoreItem(title: "Atmosphere", score: score)
                                                }
                                                if let score = review.scores.value {
                                                    ScoreItem(title: "Value", score: score)
                                                }
                                            }
                                        }
                                    default:
                                        Label {
                                            Text("Not Supported")
                                        } icon: {
                                            Image(systemName: "exclamationmark.triangle")
                                        }
                                        .cfont(.caption2)
                                        .foregroundStyle(.tertiary)
                                    }
                                }
                                .padding(.bottom, 50)
                            }
                            .scrollIndicators(.never)
                        } else {
                            Label {
                                Text("Loading")
                            } icon: {
                                Image(systemName: "arrow.down.circle.dotted")
                            }
                            .cfont(.caption2)
                            .foregroundStyle(.tertiary)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .ignoresSafeArea()
                    .tag(index)
                }
            }
            .tabViewStyle(.page)
            .ignoresSafeArea()
        }
        .onChange(of: vm.selection) { value in
            Task {
                await vm.showActivity(activity: clusteredMapActivity.items[value])
            }
        }
        .task {
            if let first = clusteredMapActivity.first {
                await vm.showActivity(activity: first)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    vm.show = true
                }
            }
        }
        .presentationDetents([.medium, .fraction(0.99)])
    }
    
    @ViewBuilder
    private func TaggedUser(_ user: UserEssentials) -> some View {
        HStack(spacing: 5) {
            ProfileImage(user.profileImage, size: 28)
            
            Text(user.username)
                .cfont(.caption)
                .foregroundStyle(.white)
                .fontWeight(.medium)
            
            Image(systemName: "chevron.forward")
                .font(.system(size: 10))
                .fontWeight(.bold)
            
            Spacer()
        }
        .onTapGesture {
            AppData.shared.goToUser(user.id)
        }
    }
}

private struct ScoreItem: View {
    let title: String
    let score: Double
    
    @State var show = false
    
    var body: some View {
        HStack {
            Text(title)
                .frame(width: 140, alignment: .leading)
                .cfont(.body)
                .fontWeight(.medium)
                .onAppear {
                    withAnimation {
                        self.show = true
                    }
                }
            
            AnimatedStarRating(score: score, activeColor: Color.gold, size: 16, show: show)
            
            Spacer()
        }
    }
}
