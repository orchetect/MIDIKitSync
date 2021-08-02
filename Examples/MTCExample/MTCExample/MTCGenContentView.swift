//
//  MTCGenContentView.swift
//  MTCExample
//  MIDIKitSync • https://github.com/orchetect/MIDIKitSync
//

import Combine
import SwiftUI
import MIDIKitSync
import TimecodeKit
import OTCore
import SwiftRadix

struct MTCGenContentView: View {
    
    weak var midiManager: MIDI.IO.Manager?
    
    init(midiManager: MIDI.IO.Manager?) {
        // normally in SwiftUI we would pass midiManager in as an EnvironmentObject
        // but that only works on macOS 11.0+ and for sake of backwards compatibility
        // we will do it old-school weak delegate storage pattern
        self.midiManager = midiManager
    }
    
    // MARK: - MIDI state
    
    @State var mtcGen: MIDI.MTC.Generator = .init()
    
    @State var localFrameRate: Timecode.FrameRate = ._24
    
    @State var locateBehavior: MIDI.MTC.Encoder.FullFrameBehavior = .ifDifferent
    
    // MARK: - UI state
    
    @State var mtcGenState = false
    
    @State var generatorTC: String = ""
    
    // MARK: - Internal State
    
    @State private var lastSeconds = 0
    
    // MARK: - View
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 8) {
            
            Text(generatorTC)
                .font(.system(size: 48, weight: .regular, design: .monospaced))
                .frame(maxWidth: .infinity)
            
            Spacer()
                .frame(height: 20)
            
            Button("Locate to " + TCC(h: 1, m: 00, s: 00, f: 00).toTimecode(rawValuesAt: localFrameRate).stringValue) {
                locate(to: TCC(h: 1, m: 00, s: 00, f: 00))
            }
            .disabled(mtcGenState)
            
            HStack(alignment: .center, spacing: 8) {
                Button("Start") {
                    mtcGenState = true
                    if mtcGen.localFrameRate != localFrameRate {
                        // update generator frame rate by triggering a locate
                        locate()
                    }
                    mtcGen.start()
                }
                .disabled(mtcGenState)
                
                Button("Stop") {
                    mtcGenState = false
                    mtcGen.stop()
                }
                .disabled(!mtcGenState)
            }
            
            Spacer()
                .frame(height: 20)
            
            Picker("Local Frame Rate", selection: $localFrameRate) {
                ForEach(Timecode.FrameRate.allCases) { fRate in
                    Text(fRate.stringValue)
                        .tag(fRate)
                }
            }
            .frame(width: 250)
            .disabled(mtcGenState)
            .onHover { _ in
                guard !mtcGenState else { return }
                
                // this is a stupid SwiftUI workaround, but it works fine for our purposes
                if mtcGen.localFrameRate != localFrameRate {
                    locate()
                }
            }
            
            Text("will be transmit as \(localFrameRate.mtcFrameRate.stringValue)")
            
            Spacer()
                .frame(height: 20)
            
            Picker("Locate Behavior", selection: $locateBehavior) {
                ForEach(MIDI.MTC.Encoder.FullFrameBehavior.allCases, id: \.self) { locateBehaviorType in
                    Text(locateBehaviorType.nameForUI)
                        .tag(locateBehaviorType)
                }
            }
            .frame(width: 250)
            .disabled(mtcGenState)
            .onHover { _ in
                guard !mtcGenState else { return }
                
                // this is a stupid SwiftUI workaround, but it works fine for our purposes
                if mtcGen.locateBehavior != locateBehavior {
                    mtcGen.locateBehavior = locateBehavior
                }
            }
            
        }
        .frame(minWidth: 400, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity, alignment: .center)
        .onAppear {
            
            // create MTC generator MIDI endpoint
            do {
                let udKey = "\(midiSources.MTCGen.tag) - Unique ID"
                
                try midiManager?.addOutput(
                    name: midiSources.MTCGen.name,
                    tag: midiSources.MTCGen.tag,
                    uniqueID: .userDefaultsManaged(key: udKey))
            } catch {
                Log.error(error)
            }
            
            // set up new MTC receiver and configure it
            mtcGen = MIDI.MTC.Generator(
                name: "main",
                midiOutHandler: { midiEvents in
                    try? midiManager?
                        .managedOutputs[midiSources.MTCGen.tag]?
                        .send(events: midiEvents)
                    
                    DispatchQueue.main.async {
                        let tc = mtcGen.timecode
                        generatorTC = tc.stringValue
                        
                        if tc.seconds != lastSeconds {
                            if mtcGenState { playClickA() }
                            lastSeconds = tc.seconds
                        }
                    }
                }
            )
            
            mtcGen.locateBehavior = locateBehavior
            
            locate()
            
        }
        
    }
    
    /// Locate to a timecode, or 00:00:00:00 by default.
    func locate(to components: Timecode.Components = TCC(h: 00, m: 00, s: 00, f: 00)) {
        
        let tc = components.toTimecode(rawValuesAt: localFrameRate)
        generatorTC = tc.stringValue
        mtcGen.locate(to: tc)
        
    }
    
}

struct mtcGenContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        MTCGenContentView(midiManager: nil)
    }
    
}
