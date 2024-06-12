//
//  ToastItem.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 6/3/24.
//

import SwiftUI

struct ToastItem: View {
    static let dragRemoveThreshold: Double = 65
    
    private let toast: Toast
    
    @State private var remainingTime: Double
    private let duration: Double
    
    init(_ toast: Toast) {
        self.toast = toast
        if let expiresAt = toast.expiresAt {
            self._remainingTime = State(initialValue: expiresAt.timeIntervalSinceNow)
            self.duration = expiresAt.timeIntervalSince(toast.createdAt)
        } else {
            self._remainingTime = State(initialValue: .zero)
            self.duration = 1
        }
    }
    
    @ObservedObject private var toastVM = ToastVM.shared
    
    @Environment(\.mainWindowSize) private var mainWindowSize
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(toast.title)
                .font(.custom(style: .body))
                .foregroundStyle(toast.type.color)
                .fontWeight(.semibold)
                .padding(.leading, 16)
                .offset(y: -8)
            
            Text(toast.message)
                .font(.custom(style: .caption))
                .foregroundStyle(.primary)
            
            HStack {
                Spacer()
                
                if case .systemError(_, _, _, _) = toast.type {
                    Button {
                        Task {
                            await toastVM.report(toast: toast)
                        }
                    } label: {
                        Text("Report")
                            .font(.custom(style: .caption2))
                    }
                    .buttonStyle(.bordered)
                }
                
                if let redirect = toast.redirect {
                    Button {
                        toastVM.remove(id: toast.id)
                        AppData.shared.goTo(redirect)
                    } label: {
                        Text("View")
                            .font(.custom(style: .caption2))
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .background(.bar, in: RoundedRectangle(cornerRadius: 10))
        .background(Color.themePrimary, in: RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 10)
        .overlay(alignment: .bottom) {
            if toast.expiresAt != nil {
                GeometryReader { geometry in
                    ZStack(alignment: .bottomLeading) {
                        Rectangle()
                            .frame(height: 3)
                            .foregroundColor(Color.black.opacity(0.2))
                        
                        Rectangle()
                            .frame(width: (remainingTime / max(duration, 1)) * geometry.size.width, height: 3)
                            .foregroundColor(.white.opacity(0.7))
                            .animation(.linear(duration: 0.5), value: remainingTime)
                    }
                    .onAppear {
                        startTimer()
                    }
                }
                .frame(height: 5)
                .clipShape(.rect(cornerRadius: 10))
            }
        }
        .overlay(alignment: .topLeading) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundStyle(.themePrimary)
                    .frame(width: 32, height: 32)
                    .shadow(radius: 3)
                
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.themeBorder, lineWidth: 2)
                    .frame(width: 32, height: 32)
                
                Image(systemName: toast.type.icon)
                    .foregroundStyle(toast.type.color)
            }
            .offset(x: -6, y: -6)
        }
        .opacity(
            toastVM.dragToast.id == toast.id && abs(toastVM.dragToast.amount) > 10
            ? 1 - min(0.9, Double(abs(toastVM.dragToast.amount) / Self.dragRemoveThreshold))
            : 1
        )
        .offset(y: toastVM.dragToast.id == toast.id ? toastVM.dragToast.amount : 0)
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged({ gesture in
                    toastVM.dragToast = (min(gesture.translation.height, 0), toast.id)
                    if toast.expiresAt != nil {
                        toastVM.persist(with: toast.id)
                    }
                })
                .onEnded({ gesture in
                    withAnimation {
                        toastVM.dragToast = (.zero, nil)
                    }
                    if gesture.translation.height < -Self.dragRemoveThreshold {
                        toastVM.remove(id: toast.id)
                    }
                })
        )
        .onTapGesture {
            if toast.expiresAt != nil {
                toastVM.persist(with: toast.id)
            }
        }
        .transition(AnyTransition.asymmetric(insertion: .push(from: .top), removal: .identity))
        .padding(.horizontal)
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if let expiresAt = toast.expiresAt {
                let timeRemaining = expiresAt.timeIntervalSinceNow
                self.remainingTime = max(timeRemaining, 0)
                if timeRemaining < 0 {
                    timer.invalidate()
                }
            } else {
                timer.invalidate()
            }
        }
    }
}

#Preview {
    ToastItem(Toast(type: .success, title: "Success", message: "Test message"))
}
