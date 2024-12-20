//
//  AudioCapture.swift
//  AubioBPMDetector
//
//  Created by Andrew Higbee on 12/20/24.
//

import AVFoundation
import Accelerate

class AudioCapture: ObservableObject {
    private let audioEngine = AVAudioEngine()
    private var bpmDetector: AubioBPMDetector

    @Published var currentBPM: Float = 0.0

    private let bufferSize: UInt32
    public let hopSize: UInt32
    private let sampleRate: UInt32

    init(bufferSize: UInt32 = 1024, hopSize: UInt32 = 512, sampleRate: UInt32 = 44100) {
        self.bufferSize = bufferSize
        self.hopSize = hopSize
        self.sampleRate = sampleRate

        bpmDetector = AubioBPMDetector(bufferSize: bufferSize, hopSize: hopSize, sampleRate: sampleRate)
    }

    func startCapturing() {
        if audioEngine.isRunning {
            print("Audio engine is already running.")
            return
        }

        let inputNode = audioEngine.inputNode
        let bus = 0
        let inputFormat = inputNode.outputFormat(forBus: bus)

        // Remove any existing tap before adding a new one
        inputNode.removeTap(onBus: bus)

        inputNode.installTap(onBus: bus, bufferSize: 512, format: inputFormat) { [weak self] buffer, _ in
            guard let self = self else { return }
            self.processAudio(buffer: buffer)
        }

        do {
            try audioEngine.start()
            print("Audio engine started successfully")
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }

    func stopCapturing() {
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        print("Audio engine stopped.")
    }

    private func applyNoiseGate(to audioData: [Float], threshold: Float) -> [Float] {
        return audioData.map { abs($0) < threshold ? 0.0 : $0 }
    }

    private func applyLowPassFilter(input: [Float], cutoffFrequency: Float, sampleRate: Float) -> [Float] {
        // Initialize the output array
        var output = [Float](repeating: 0.0, count: input.count)
        
        // Calculate RC (resistance-capacitance) time constant
        let dt = 1.0 / sampleRate
        let rc = 1.0 / (2 * .pi * cutoffFrequency)
        let alpha = dt / (rc + dt) // Smoothing factor
        
        // Apply the low-pass filter
        for i in 1..<input.count {
            output[i] = output[i - 1] + alpha * (input[i] - output[i - 1])
        }
        
        return output
    }

    private func processAudio(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        var frameLength = Int(buffer.frameLength)

        // Extract audio data
        var audioData = Array(UnsafeBufferPointer(start: channelData, count: frameLength))
        
        // Ensure the audioData matches the hopSize
        if frameLength < bpmDetector.hopSize {
            // Zero-pad the buffer if it's smaller than hopSize
            audioData += Array(repeating: 0.0, count: Int(bpmDetector.hopSize) - frameLength)
            frameLength = Int(bpmDetector.hopSize)
        } else if frameLength > bpmDetector.hopSize {
            // Truncate the buffer if it's larger than hopSize
            audioData = Array(audioData.prefix(Int(bpmDetector.hopSize)))
            frameLength = Int(bpmDetector.hopSize)
        }

        // Apply the low-pass filter
        let filteredData = applyLowPassFilter(input: audioData, cutoffFrequency: 200.0, sampleRate: 44100.0)
        
        // Apply noise gate to suppress quiet background noise
        let cleanedData = applyNoiseGate(to: filteredData, threshold: 0.02)

        DispatchQueue.global(qos: .userInitiated).async {
            self.bpmDetector.process(audioData: filteredData)
            let bpm = self.bpmDetector.getBPM()
            DispatchQueue.main.async {
                if bpm > 0 {
                    self.currentBPM = bpm
                }
            }
        }
    }
}
