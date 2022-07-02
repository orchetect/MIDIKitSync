//
//  MTC Generator Tests.swift
//  MIDIKitSync • https://github.com/orchetect/MIDIKitSync
//

#if shouldTestCurrentPlatform

import XCTest
@testable import MIDIKitSync
import TimecodeKit

final class MTC_Generator_Generator_Tests: XCTestCase {
    
    func testMTC_Generator_Default() {
        
        // just testing variations on syntax
        
        let mtcGen1 = MIDI.MTC.Generator()
        mtcGen1.midiOutHandler = { [weak self] (midiMessage) in
            _ = self
            _ = midiMessage
        }
        
        let _ = MIDI.MTC.Generator { [weak self] (midiMessage) in
            _ = self
            _ = midiMessage
        }
        
        let _ = MIDI.MTC.Generator(midiOutHandler: { (midiMessage) in
            _ = midiMessage
        })
        
        let _ = MIDI.MTC.Generator { (midiMessage) in
            _ = midiMessage
        }
        
    }
    
}

#endif
