//
//  Stress Tests.swift
//  MIDIKitSync • https://github.com/orchetect/MIDIKitSync
//

#if !os(watchOS)

import XCTest
@testable import MIDIKitSync
import CoreMIDI

final class StressTests: XCTestCase {
    
    func testThreadingMTCGenerator() {
        
        // MARK: - Generator
        
        let mtcGen = MIDI.MTC.Generator { midiMessage in
            _ = midiMessage
        }
        
        // test public properties and methods
        // to make sure we don't encounter thread-related crashes
        
        func access() {
            // public properties (set and get where applicable)
            _ = mtcGen.name
            _ = mtcGen.mtcFrameRate
            _ = mtcGen.state
            _ = mtcGen.timecode
            _ = mtcGen.localFrameRate
            _ = mtcGen.locateBehavior
            mtcGen.locateBehavior = .always
            _ = mtcGen.midiOutHandler
            mtcGen.midiOutHandler = { _ in }
            
            // public methods
            mtcGen.locate(to: Timecode(at: ._24))
            mtcGen.locate(to: TCC())
            mtcGen.start()
            mtcGen.stop()
            mtcGen.start(at: Timecode(at: ._24))
            mtcGen.stop()
            mtcGen.start(at: TCC(), frameRate: ._24)
            mtcGen.stop()
            mtcGen.start(at: 0.0, frameRate: ._24)
            mtcGen.stop()
        }
        
        // from same thread as its allocation
        access()
        
        // from different thread
        DispatchQueue.global().sync {
            access()
        }
        
    }
    
    func testThreadingMTCReceiver() {
        
        // MARK: - Receiver
        
        // (Receiver.midiIn() is async internally so we need to wait for property updates to occur before reading them)
        
        // init with local frame rate
        let mtcRec = MIDI.MTC.Receiver(name: "test", initialLocalFrameRate: ._24)
        { timecode, messageType, direction, displayNeedsUpdate in
            _ = timecode
            _ = messageType
            _ = direction
            _ = displayNeedsUpdate
        } stateChanged: { state in
            _ = state
        }
        
        // test public properties and methods
        // to make sure we don't encounter thread-related crashes
        
        func access() {
            // public properties (set and get where applicable)
            _ = mtcRec.state
            _ = mtcRec.timecode
            _ = mtcRec.localFrameRate
            mtcRec.localFrameRate = ._30
            _ = mtcRec.mtcFrameRate
            _ = mtcRec.direction
            _ = mtcRec.syncPolicy
            mtcRec.syncPolicy = .init()
            _ = mtcRec.timecodeChangedHandler
            mtcRec.timecodeChangedHandler = { _,_,_,_ in }
            
            // public methods
            // (none)
        }
        
        // from same thread as its allocation
        access()
        
        // from different thread
        DispatchQueue.global().sync {
            access()
        }
        
    }
    
}

#endif
