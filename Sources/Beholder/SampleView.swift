//
//  SampleView.swift
//  Beholder
//
//  Created by Ben Gottlieb on 3/31/26.
//

import SwiftUI

public extension Beholder {
    @BeholderValue(default: false) var isReady: Bool
}

struct SampleView: View {
    @Beholding(\.isReady) var isReady
    var body: some View {
        VStack {
            Text("Hello, World! \(isReady ? "Ready" : "Idle")")
            Button("Toggle") {
                Task.detached {
                    Beholder.isReady.toggle()
                }
            }
        }
    }
}

#Preview {
    SampleView()
}
