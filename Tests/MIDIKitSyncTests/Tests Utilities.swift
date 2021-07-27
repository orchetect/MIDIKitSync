//
//  Tests Utilities.swift
//  MIDIKitSync • https://github.com/orchetect/MIDIKitSync
//

#if !os(watchOS)
import XCTest

extension XCTestCase {
    
    /// Simple XCTest wait timer that does not block the runloop
    /// - Parameter timeout: floating-point duration in seconds
    public func `XCTWait`(sec timeout: Double) {
        
        let delayExpectation = XCTestExpectation()
        delayExpectation.isInverted = true
        wait(for: [delayExpectation], timeout: timeout)
        
    }
    
}
#endif
