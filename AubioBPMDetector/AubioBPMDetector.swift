//
//  AubioBPMDetector.swift
//  AubioBPMDetector
//
//  Created by Andrew Higbee on 12/20/24.
//

import Foundation

import Foundation

class AubioBPMDetector {
    public var tempoObject: OpaquePointer?
    private let bufferSize: UInt32
    public let hopSize: UInt32
    private let sampleRate: UInt32

    init(bufferSize: UInt32, hopSize: UInt32, sampleRate: UInt32) {
        self.bufferSize = bufferSize
        self.hopSize = hopSize
        self.sampleRate = sampleRate

        // Initialize the tempo detector
        tempoObject = createTempoDetector("default", bufferSize, hopSize, sampleRate)
        if tempoObject == nil {
            print("Failed to initialize tempo detector")
        }
    }

    deinit {
        // Clean up the tempo detector
        if let tempoObject = tempoObject {
            destroyTempoDetector(tempoObject)
        }
    }
    
    func getBPM() -> Float {
        guard let tempoObject = tempoObject else {
            print("Tempo detector is not initialized.")
            return 0.0
        }
        return getBPMFromTempo(tempoObject)
    }

    func process(audioData: [Float]) {
        guard let tempoObject = tempoObject else { return }

        // Create a mutable copy of the audio data
        var mutableAudioData = audioData

        mutableAudioData.withUnsafeMutableBufferPointer { bufferPointer in
            guard let floatPointer = bufferPointer.baseAddress else { return }
            processAudioWithTempo(tempoObject, floatPointer, UInt32(hopSize))
        }
    }
}
