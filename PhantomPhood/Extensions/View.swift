//
//  View.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/4/23.
//

import Foundation
import SwiftUI
import Combine

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func withFilledStyle(
        size: TextFieldSize = .medium,
        color: Color = Color.themePrimary,
        paddingLeading: CGFloat? = nil,
        paddingTrailing: CGFloat? = nil
    ) -> some View {
        modifier(FilledTextFieldViewModifier(size: size, paddingLeading: paddingLeading, paddingTrailing: paddingTrailing, color: color))
    }
}

struct NavigationDestinationViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .leaderboard:
                    LeaderboardView()
                case .inbox:
                    InboxView()
                case .conversation(let args):
                    switch args {
                    case .id(let id):
                        ConversationView(id: id)
                    case .user(let user):
                        ConversationView(user: user)
                    }
                case .userActivity(let id):
                    UserActivityView(id: id)
                    
                    // Actions
                case let .checkIn(placeIdentifier, event):
                    if let event {
                        NewCheckInView(event: event)
                    } else {
                        NewCheckInView(placeIdentifier)
                    }
                case .report(let item):
                    ReportView(item: item)
                    
                    // Place
                    
                case .place(let id, let action):
                    PlaceView(id: id, action: action)
                case .placeMapPlace(let mapPlace, let action):
                    PlaceView(mapPlace: mapPlace, action: action)
                    
                    // Event
                    
                case .event(let idOrData):
                    EventView(idOrData)
                    
                    // My Profile
                    
                case .settings:
                    SettingsView()
                case .paymentsSetting:
                    PaymentsSettingView()
                case .myConnections(let initTab):
                    MyConnections(activeTab: initTab)
                case .requests:
                    RequestsView()
                case .myActivities(let vm, let selected):
                    MyActivitiesView(vm: vm, selected: selected?.id)
                    
                    // User
                    
                case .userProfile(let idOrUsername):
                    if idOrUsername.starts(with: "@") {
                        UserProfileView(username: idOrUsername.replacingOccurrences(of: "@", with: ""))
                    } else {
                        UserProfileView(id: idOrUsername)
                    }
                case .userConnections(let userId, let initTab):
                    UserConnectionsView(userId: userId, activeTab: initTab)
                case .userActivities(let vm, let selected):
                    UserProfileActivitiesView(vm: vm, selected: selected?.id)
                case .userCheckins(let userId):
                    ProfileCheckinsView(userId: userId)
                    
                case .placesList(let listId):
                    PlacesListView(listId: listId)
                }
            }
    }
}

extension View {
    func handleNavigationDestination() -> some View {
        modifier(NavigationDestinationViewModifier())
    }
}

extension View {
    func cfont(_ textStyle: Font.TextStyle) -> some View {
        modifier(CustomFontViewModifier(textStyle: textStyle))
    }
}
