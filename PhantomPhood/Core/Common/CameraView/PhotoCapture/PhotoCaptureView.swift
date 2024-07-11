//
//  PhotoCaptureView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/27/24.
//

import SwiftUI

struct PhotoCaptureView: View {
    @StateObject private var vm = PhotoCaptureVM()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    private let onCompletion: (Data) -> Void
    
    init(onCompletion: @escaping (Data) -> Void) {
        self.onCompletion = onCompletion
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let error = vm.error {
                VStack {
                    Text(error.localizedDescription)
                    
                    if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
                        Button {
                            openURL(appSettingsURL)
                        } label: {
                            Text("Settings")
                        }
                    }
                }
                .cfont(.body)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                if vm.isTaken, let picData = vm.picData, let uiImage = UIImage(data: picData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .ignoresSafeArea(edges: .top)
                    
                } else if let aspectRatio = vm.aspectRatio {
                    GeometryReader { geometry in
                        CameraPreview(
                            vm: vm,
                            size: CGSize(width: geometry.size.width, height: Double(max(aspectRatio.height, aspectRatio.width)) * (geometry.size.width / Double(min(aspectRatio.height, aspectRatio.width))))
                        )
                        .frame(height: Double(max(aspectRatio.height, aspectRatio.width)) * (geometry.size.width / Double(min(aspectRatio.height, aspectRatio.width))))
                        .frame(maxWidth: .infinity)
                        .ignoresSafeArea(edges: .top)
                    }
                } else {
                    Spacer()
                }
            }
            
            HStack {
                ZStack {
                    if vm.isTaken {
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            vm.retake()
                        } label: {
                            Circle()
                                .stroke(Color.white, style: StrokeStyle(lineWidth: 1, dash: [1, 1]))
                                .foregroundStyle(Color.white)
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Image(systemName: "arrow.2.squarepath")
                                        .foregroundStyle(Color.white)
                                        .font(.system(size: 16))
                                        .fontWeight(.semibold)
                                }
                        }
                        .padding(.trailing, 5)
                        .transition(AnyTransition.opacity.combined(with: .scale).animation(.bouncy))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                
                Button {
                    if vm.isTaken {
                        if let picData = vm.picData {
                            onCompletion(picData)
                            dismiss()
                        }
                    } else {
                        vm.capturePhoto()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .foregroundStyle(vm.isTaken ? Color.green.opacity(0.8) : Color.white.opacity(vm.isLoading ? 0.5 : 1))
                            .frame(width: vm.isTaken ? 55 : 60, height: vm.isTaken ? 55 : 60)
                            .animation(.bouncy, value: vm.isTaken)
                            .zIndex(2)
                        
                        if vm.isTaken {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.white)
                                .font(.system(size: 26))
                                .fontWeight(.semibold)
                                .transition(AnyTransition.opacity.combined(with: .scale).animation(.bouncy))
                                .zIndex(3)
                        } else {
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .foregroundStyle(Color.white)
                                .frame(width: 70, height: 70)
                                .transition(AnyTransition.opacity.combined(with: .scale).animation(.bouncy))
                                .zIndex(1)
                        }
                    }
                }
                .disabled(vm.isLoading)
                
                Color.clear
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(height: 75)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
        }
        .onAppear(perform: vm.start)
        
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Label {
                        Text("Back")
                    } icon: {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 22))
                    }
                }
                
                Spacer()
                
                Button {
                    vm.toggleCamera()
                } label: {
                    Group {
                        if #available(iOS 17.0, *) {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .symbolEffect(.bounce, value: vm.currentCameraType)
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                        }
                    }
                    .font(.system(size: 22))
                }
            }
            .cfont(.headline)
            .fontWeight(.medium)
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

#Preview {
    ZStack {
        PhotoCaptureView(onCompletion: { _ in })
    }
}
