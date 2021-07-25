//
//  MTC Generator Tests.swift
//  MIDIKitSync • https://github.com/orchetect/MIDIKitSync
//

#if !os(watchOS)

import XCTest
@testable import MIDIKitSync
import TimecodeKit

final class MTC_Generator_Generator_Tests: XCTestCase {
    
    func testMTC_Generator_Default() {
        
        let mtcGen1 = MIDI.MTC.Generator()
        mtcGen1.midiOutHandler = { [weak self] (midiMessage) in
            // send midi message here
            _ = midiMessage
            self?.XCTWait(sec: 0.0)
        }
        
        let _ = MIDI.MTC.Generator { [weak self] (midiMessage) in
            // send midi message here
            _ = midiMessage
            self?.XCTWait(sec: 0.0)
        }
        
        let _ = MIDI.MTC.Generator(midiOutHandler: { (midiMessage) in
            //yourMIDIPort.send(midiBytes)
            _ = midiMessage
        })
        
        let _ = MIDI.MTC.Generator { (midiMessage) in
            //yourMIDIPort.send(midiBytes)
            _ = midiMessage
        }
        
    }
    
}

#endif
