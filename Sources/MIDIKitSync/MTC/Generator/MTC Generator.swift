//
//  MTC Generator.swift
//  MIDIKitSync • https://github.com/orchetect/MIDIKitSync
//

import Foundation
import MIDIKit
import TimecodeKit

extension MIDI.MTC {
    
    /// MTC sync generator.
    public class Generator: SendsMIDIEvents {
        
        // MARK: - Public properties
        
        public private(set) var name: String
        
        /// The MTC SMPTE frame rate (24, 25, 29.97d, or 30) that was last transmitted by the generator.
        ///
        /// This property should only be inspected purely for developer informational or diagnostic purposes. For production code or any logic related to MTC, it should be ignored -- only the local `timecode.frameRate` property is used for automatic selection of MTC SMPTE frame rate and scaling of outgoing timecode accordingly.
        public var mtcFrameRate: MTCFrameRate {
            
            var getMTCFrameRate: MTCFrameRate!
            
            queue.sync {
                getMTCFrameRate = encoder.mtcFrameRate
            }
            
            return getMTCFrameRate
            
        }
        
        @MIDI.AtomicAccess
        public private(set) var state: State = .idle
        
        /// Internal var
        @MIDI.AtomicAccess
        private var shouldStart = true
        
        /// Property updated whenever outgoing MTC timecode changes.
        public var timecode: Timecode {
            
            var getTimecode: Timecode!
            
            queue.sync {
                getTimecode = encoder.timecode
            }
            
            return getTimecode
            
        }
        
        public var localFrameRate: Timecode.FrameRate {
            
            var getFrameRate: Timecode.FrameRate!
            
            queue.sync {
                getFrameRate = encoder.localFrameRate
            }
            
            return getFrameRate
            
        }
        
        /// Behavior determining when MTC Full-Frame MIDI messages should be generated.
        ///
        /// `.ifDifferent` is recommended and suitable for most implementations.
        @MIDI.AtomicAccess
        public var locateBehavior: MIDI.MTC.Encoder.FullFrameBehavior = .ifDifferent
        
        
        // MARK: - Stored closures
        
        /// Closure called every time a MIDI message needs to be transmitted by the generator.
        ///
        /// - Note: Handler is called on a dedicated thread so do not make UI updates from it.
        public var midiOutHandler: MIDIOutHandler? = nil
        
        // MARK: - init
        
        public init(
            name: String? = nil,
            midiOutHandler: MIDIOutHandler? = nil
        ) {
            
            // handle init arguments
            
            let name = name ?? UUID().uuidString
            
            self.name = name
            
            self.midiOutHandler = midiOutHandler
            
            // queue
            
            queue = DispatchQueue(label: "midikit.mtcgenerator.\(name)",
                                  qos: .userInteractive)
            
            // timer
            
            timer = MIDI.SafeDispatchTimer(rate: .seconds(1.0), // default, will be changed later
                                           queue: queue,
                                           eventHandler: { })
            
            timer.setEventHandler { [weak self] in
                
                guard let strongSelf = self else { return }
                
                strongSelf.timerFired()
                
            }
            
            queue.sync {
                
                // encoder setup
                
                encoder = Encoder()
                
                encoder.midiOutHandler = { [weak self] midiEvents in
                    
                    guard let strongSelf = self else { return }
                    
                    strongSelf.midiOut(midiEvents)
                    
                }
                
            }
            
        }
        
        
        // MARK: - Queue (internal)
        
        /// Maintain a high-priority internal thread
        internal var queue: DispatchQueue
        
        
        // MARK: - Encoder (internal)
        
        internal var encoder = Encoder()
        
        
        // MARK: - Timer (internal)
        
        internal var timer: MIDI.SafeDispatchTimer
        
        /// Internal: Fired from our timer object.
        internal func timerFired() {
            
            encoder.increment()
            
        }
        
        /// Sets timer rate to corresponding MTC quarter-frame duration in Hz.
        internal func setTimerRate(from frameRate: Timecode.FrameRate) {
            
            // const values generated from:
            // TCC(f: 1).toTimecode(at: frameRate)!.realTimeValue
            
            // duration in seconds for one quarter-frame
            let rate: Double
            
            switch frameRate {
            case ._23_976:      rate = 0.010427083333333333
            case ._24:          rate = 0.010416666666666666
            case ._24_98:       rate = 0.010009999999999998
            case ._25:          rate = 0.01
            case ._29_97:       rate = 0.008341666666666666
            case ._29_97_drop:  rate = 0.008341666666666666
            case ._30:          rate = 0.008333333333333333
            case ._30_drop:     rate = 0.008341666666666666
            case ._47_952:      rate = 0.010427083333333333
            case ._48:          rate = 0.010416666666666666
            case ._50:          rate = 0.01
            case ._59_94:       rate = 0.008341666666666666
            case ._59_94_drop:  rate = 0.008341666666666666
            case ._60:          rate = 0.008333333333333333
            case ._60_drop:     rate = 0.008341666666666666
            case ._100:         rate = 0.01
            case ._119_88:      rate = 0.008341666666666666
            case ._119_88_drop: rate = 0.008341666666666666
            case ._120:         rate = 0.008333333333333333
            case ._120_drop:    rate = 0.008341666666666666
            }
            
            timer.setRate(.seconds(rate))
            
        }
        
        
        // MARK: - Public methods
        
        /// Locate to a new timecode, while not generating continuous playback MIDI message stream.
        /// Sends a MTC full-frame message.
        ///
        /// - Note: `timecode` may contain subframes > 0 to locate; subframes will be stripped prior to transmitting the full-frame message since the resolution of MTC full-frame messages is 1 frame.
        ///
        /// However, if subframes is > 0, you should not call `.start()` subsequently as it will not synchronize correctly. Instead, call `.start(now:)`.
        public func locate(to timecode: Timecode) {
            
            queue.sync {
                
                encoder.locate(to: timecode, transmitFullFrame: locateBehavior)
                setTimerRate(from: encoder.localFrameRate)
                
            }
            
        }
        
        /// Locate to a new timecode, while not generating continuous playback MIDI message stream.
        /// Sends a MTC full-frame message.
        ///
        /// - Note: `components` may contain subframes > 0 to locate; subframes will be stripped prior to transmitting the full-frame message since the resolution of MTC full-frame messages is 1 frame.
        ///
        /// However, if subframes is > 0, you should not call `.start()` subsequently as it will not synchronize correctly. Instead, call `.start(now:)`.
        public func locate(to components: Timecode.Components) {
            
            queue.sync {
                
                encoder.locate(to: components, transmitFullFrame: locateBehavior)
                setTimerRate(from: encoder.localFrameRate)
                
            }
            
        }
        
        /// Starts generating MTC continuous playback MIDI message stream events.
        /// Call this method at the exact time that `timecode` occurs.
        ///
        /// Frame rate will be derived from the `timecode` object passed in.
        ///
        /// - Note: It is not necessary to send a `locate(to:)` message simultaneously or immediately prior, and is actually undesirable as it can confuse the receiving entity.
        ///
        /// Call `stop()` to stop generating events.
        public func start(now timecode: Timecode) {
            
            // if subframes == 0, no scheduling is required
            
            if timecode.subFrames == 0 {
                
                locateAndStart(now: timecode.components,
                               frameRate: timecode.frameRate)
                
                return
                
            }
            
            // if subframes > 0, scheduling is required to synchronize
            // MTC generation start to be at the exact start of the next frame
            
            // pass it on to the start method that handles scheduling
            
            start(now: timecode.realTimeValue,
                  frameRate: timecode.frameRate)
            
        }
        
        /// Starts generating MTC continuous playback MIDI message stream events.
        /// Call this method at the exact time that `realTime` occurs.
        ///
        /// - Note: It is not necessary to send a `locate(to:)` message simultaneously or immediately prior, and is actually undesirable as it can confuse the receiving entity.
        ///
        /// Call `stop()` to stop generating events.
        public func start(now components: Timecode.Components,
                          frameRate: Timecode.FrameRate,
                          base: Timecode.SubFramesBase) {
            
            let tc = Timecode(rawValues: components,
                              at: frameRate,
                              base: base)
            
            start(now: tc)
            
        }
        
        /// Starts generating MTC continuous playback MIDI message stream events.
        /// Call this method at the exact time that `realTime` occurs.
        ///
        /// - Note: It is not necessary to send a `locate(to:)` message simultaneously or immediately prior, and is actually undesirable as it can confuse the receiving entity.
        ///
        /// Call `stop()` to stop generating events.
        public func start(now realTime: TimeInterval,
                          frameRate: Timecode.FrameRate) {
            
            // since realTime can be between frames,
            // we need to ensure that MTC quarter-frames begin generating
            // on the start of an exact frame.
            // this may involve scheduling the start of MTC generation
            // to be in the near future (on the order of milliseconds)
            
            let nsInDispatchTime = DispatchTime.now().uptimeNanoseconds
            
            // convert real time to timecode at the given frame rate
            guard let tc = try? Timecode(
                realTimeValue: realTime,
                at: frameRate,
                limit: ._24hours,
                base: ._100SubFrames // base doesn't matter, just for calculation
            ) else { return }
            
            // if subframes == 0, no scheduling is required
            
            if tc.subFrames == 0 {
                locateAndStart(now: tc.components,
                               frameRate: tc.frameRate)
                return
            }
            
            // if the resulting timecode is near enough to the realTime
            // supplied, then no scheduling is required and we can just start
            
            let secsOfOneFrame = TCC(f: 1)
                .toTimecode(rawValuesAt: frameRate)
                .realTimeValue
            
            // arbitrary: use duration of a subframe at 100 subframes per frame
            // to determine if realTime is near enough to the start of a frame
            let secsAcceptableMargin = secsOfOneFrame / 100
            
            let secsDiffBetweenInputAndTimecode = realTime - tc.realTimeValue
            
            if secsDiffBetweenInputAndTimecode < secsAcceptableMargin {
                locateAndStart(now: tc.components,
                               frameRate: tc.frameRate)
                return
            }
            
            // otherwise, we have to schedule MTC start for the near future
            // (the exact start of the next frame)
            
            let tcAdvancedByOneFrame = tc.adding(wrapping: TCC(f: 1))
            
            let secsToStartOfNextFrame = secsOfOneFrame - secsDiffBetweenInputAndTimecode
            
            let nsecsToStartOfNextFrame = UInt64(secsToStartOfNextFrame * 1_000_000_000)
            
            let nsecsDeadline = nsInDispatchTime + nsecsToStartOfNextFrame
            
            queue.asyncAfter(deadline: .init(uptimeNanoseconds: nsecsDeadline),
                             qos: .userInteractive)
            {
                guard self.shouldStart else { return }
                
                self.locateAndStart(now: tcAdvancedByOneFrame.components,
                                    frameRate: tcAdvancedByOneFrame.frameRate)
            }
            
        }
        
        /// Internal: called from all other start(...) methods when they are finally ready to initiate the start of MTC generation.
        /// - Note: This method assumes subframes == 0.
        internal func locateAndStart(now components: Timecode.Components,
                                     frameRate: Timecode.FrameRate) {
            
            queue.sync {
                
                encoder.locate(to: components,
                               frameRate: frameRate,
                               transmitFullFrame: .never)
                
                if state == .generating {
                    timer.stop()
                }
                
                state = .generating
                
                setTimerRate(from: encoder.localFrameRate)
                timer.restart()
                
            }
            
        }
        
        /// Stops generating MTC continuous playback MIDI message stream events.
        public func stop() {
            
            shouldStart = false
            
            queue.sync {
                
                state = .idle
                
                timer.stop()
                
            }
            
        }
        
    }
    
}
