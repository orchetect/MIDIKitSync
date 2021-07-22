//
//  MIDIKitSync Extensions.swift
//  MIDIKitSyncTestHarness
//  MIDIKitSync • https://github.com/orchetect/MIDIKitSync
//

import Foundation
import MIDIKitSync

extension MIDI.MTC.Encoder.FullFrameBehavior {
    
    public var nameForUI: String {
        
        switch self {
        case .always:
            return "Always"
        case .ifDifferent:
            return "If Different"
        case .never:
            return "Never"
        }
        
    }
    
}
