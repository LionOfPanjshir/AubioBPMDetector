//
//  BPMView.swift
//  AubioBPMDetector
//
//  Created by Andrew Higbee on 12/20/24.
//

import SwiftUI

struct BPMView: View {
    @StateObject private var audioCapture = AudioCapture()

    var body: some View {
        VStack {
            Text("Real-Time BPM Detector")
                .font(.largeTitle)
                .padding()

            Text("Current BPM: \(audioCapture.currentBPM, specifier: "%.1f")")
                .font(.title)
                .padding()

            HStack {
                Button("Start") {
                    audioCapture.startCapturing()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button("Stop") {
                    audioCapture.stopCapturing()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }
}

#Preview {
    BPMView()
}
