//
//  MTC Utilities.swift
//  MIDIKitSync • https://github.com/orchetect/MIDIKitSync
//

import TimecodeKit

extension MIDI.MTC {
	
	/// Internal: Returns `true` if both tuples are considered equal.
	internal static func mtcIsEqual(
		_ lhs: (mtcComponents: Timecode.Components,
				mtcFrameRate: MTCFrameRate)?,
		_ rhs: (mtcComponents: Timecode.Components,
				mtcFrameRate: MTCFrameRate)?
	) -> Bool {
		
		guard let lhs = lhs,
			  let rhs = rhs
		else { return false }
		
		let lhsComponents = lhs.mtcComponents
		let rhsComponents = rhs.mtcComponents
		
		let componentsAreEqual =
			lhsComponents.h == rhsComponents.h &&
			lhsComponents.m == rhsComponents.m &&
			lhsComponents.s == rhsComponents.s &&
			lhsComponents.f == rhsComponents.f
		
		let mtcFrameRatesAreEqual =
			lhs.mtcFrameRate == rhs.mtcFrameRate
		
		return componentsAreEqual && mtcFrameRatesAreEqual
		
	}
	
	/// Internal: Converts MTC components and quarter frames to full-frame components
	internal static func convertToFullFrameComponents(
		mtcComponents: Timecode.Components,
		mtcQuarterFrames: UInt8
	) -> Timecode.Components {
		
		var newComponents = mtcComponents
		newComponents.f += ((25 * Int(mtcQuarterFrames)) / 100)
		
		return newComponents
		
	}
	
}
