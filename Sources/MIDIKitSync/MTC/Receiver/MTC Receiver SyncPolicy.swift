//
//  MTC Receiver SyncPolicy.swift
//  MIDIKitSync • https://github.com/orchetect/MIDIKitSync
//

@_implementationOnly import OTCore
import TimecodeKit

extension MIDI.MTC.Receiver {
    
    /// Options defining behavior of the receiver
    public struct SyncPolicy: Equatable, Codable {
        
        // MARK: - Public properties
        
        /// Sets the number of received continuous timecode frames that must elapse prior to establishing synchronization
        public var lockFrames: Int = 0
        
        /// Sets the number of timecode frames that must be missed until the receiver enters the stopped/idle state
        public var dropOutFrames: Int = 0
        
        
        // MARK: - Init
        
        public init(lockFrames: Int = 16, dropOutFrames: Int = 10) {
            
            setLockFrames(lockFrames)
            setDropOutFramesFrames(dropOutFrames)
            
        }
        
        
        // MARK: - Internal Methods
        
        internal mutating func setLockFrames(_ value: Int) {
            lockFrames = value.clamped(to: 0...100)
        }
        
        internal mutating func setDropOutFramesFrames(_ value: Int) {
            dropOutFrames = value.clamped(to: 0...100)
        }
        
        
        // MARK: - Public Methods
        
        /// Returns real time duration in seconds of the `lockFrames` property.
        public func lockDuration(at rate: Timecode.FrameRate) -> Double {
            
            let tc = Timecode(wrapping: TCC(f: lockFrames), at: rate)
            return tc.realTimeValue
            
        }
        
        /// Returns real time duration in seconds of the `dropOutFrames` property.
        public func dropOutDuration(at rate: Timecode.FrameRate) -> Double {
            
            let tc = Timecode(wrapping: TCC(f: dropOutFrames), at: rate)
            return tc.realTimeValue
            
        }
        
    }
    
}
