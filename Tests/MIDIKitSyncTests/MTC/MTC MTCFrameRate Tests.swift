//
//  MTC MTCFrameRate Tests.swift
//  MIDIKitSync • https://github.com/orchetect/MIDIKitSync
//

#if shouldTestCurrentPlatform

import XCTest
@testable import MIDIKitSync
import TimecodeKit

final class MTC_MTCFrameRate_Tests: XCTestCase {
    
    func testMTC_MTCFrameRate_Init_TimecodeFrameRate() {
        
        // test is pedantic, but worth having
        
        Timecode.FrameRate.allCases.forEach {
            
            XCTAssertEqual(MIDI.MTC.MTCFrameRate($0), $0.mtcFrameRate)
            
        }
        
    }
    
}

#endif
