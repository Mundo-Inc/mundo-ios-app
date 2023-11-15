//
//  ForYouView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/15/23.
//

import SwiftUI
import SwiftUIPager

struct ForYouView: View {
    @State private var currentIndex: Int = 0
    @State var data = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

    @StateObject var page: Page = .first()
    
    var body: some View {
        ZStack {
            Pager(page: page, data: data, id: \.self) { item in
                Color.themePrimary
                    .frame(height: UIScreen.main.bounds.height)
                    .overlay {
                        VStack {
                            Text("Item :  \(item)")
                            Text("Total: \(data.count)")
                        }
                        .font(.monospaced(Font.subheadline)())
                    }
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .foregroundStyle(.blue)
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
            }
            .pagingPriority(.simultaneous)
            .vertical()
            .singlePagination(ratio: 0.5, sensitivity: .custom(0.2))
            .onPageChanged({ pageIndex in
                guard pageIndex >= self.data.count - 5 else { return }
                guard let last = self.data.last else { return }
                let newData = (1...10).map { last + $0 }
                withAnimation {
                    self.data.append(contentsOf: newData)
                }
            })
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ForYouView()
}
