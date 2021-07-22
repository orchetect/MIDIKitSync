//
//  MTC Generator State.swift
//  MIDIKitSync • https://github.com/orchetect/MIDIKitSync
//

// MARK: - State

extension MIDI.MTC.Generator {
	
	public enum State: Equatable {
		
		/// Idle:
		/// No activity (outgoing continuous data stream stopped).
		case idle
		
		/// Generating:
		/// Generator is actively generating messages.
		case generating
		
	}
	
}

extension MIDI.MTC.Generator.State: CustomStringConvertible {
	
	public var description: String {
		
		switch self {
		case .idle:
			return "idle"
		case .generating:
			return "generating"
		}
		
	}
	
}
