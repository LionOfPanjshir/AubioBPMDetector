//
//  File.swift
//  AubioBPMDetector
//
//  Created by Andrew Higbee on 12/20/24.
//

import Foundation

class Function {
    func testAubioFunctions() {
        print("Testing Aubio Bridging Header...")
        let buffer = new_fvec(512) // Should compile if bridging works
        print("Buffer created: \(buffer)")
    }
}
