//
//  Timespec.swift
//  MIDIKitSync • https://github.com/orchetect/MIDIKitSync
//



/// ------------------------------------------------------------------------------------
/// ------------------------------------------------------------------------------------
/// Borrowed from [OTCore 1.1.8](https://github.com/orchetect/OTCore) under MIT license.
/// ------------------------------------------------------------------------------------
/// ------------------------------------------------------------------------------------



#if canImport(Darwin)

import Darwin

// Apple docs:
//
// CLOCK_MONOTONIC
// clock that increments monotonically, tracking the time since an arbitrary point, and will continue to increment while the system is asleep.
//
// CLOCK_MONOTONIC_RAW
// clock that increments monotonically, tracking the time since an arbitrary point like CLOCK_MONOTONIC. However, this clock is unaffected by frequency or time adjustments. It should not be compared to other system time sources.
//
// CLOCK_MONOTONIC_RAW_APPROX
// like CLOCK_MONOTONIC_RAW, but reads a value cached by the system at context switch. This can be read faster, but at a loss of accuracy as it may return values that are milliseconds old.
//
// CLOCK_UPTIME_RAW
// clock that increments monotonically, in the same manner as CLOCK_MONOTONIC_RAW, but that does not increment while the system is asleep. The returned value is identical to the result of mach_absolute_time() after the appropriate mach_timebase conversion is applied.

/// Returns high-precision system uptime
///
/// This is preferable to using `mach_absolute_time()` since `mach_absolute_time()` is macOS-only.
///
/// - returns: `timespec(tv_sec: Int, tv_nsec: Int)` where `tv_sec` is seconds and `tc_nsec` is nanoseconds
@available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
@inlinable internal func otc_clock_gettime_monotonic_raw() -> timespec {
    
    var uptime = timespec()
    
    if 0 != clock_gettime(CLOCK_MONOTONIC_RAW, &uptime) {
        fatalError("Could not execute clock_gettime, errno: \(errno)")
    }
    
    return uptime
    
}


// MARK: - Timespec constructors

extension timespec {
    
    /// Convenience constructor from floating point seconds value
    @inlinable internal static func newInstance<T: BinaryFloatingPoint>(floatSeconds bfp: T) -> Self {
        
        var newTimespec = timespec()
        
        let intVal = Int(bfp * 1_000_000_000)
        
        newTimespec.tv_nsec = intVal % 1_000_000_000
        
        newTimespec.tv_sec = intVal / 1_000_000_000
        
        return newTimespec
        
    }
    
}


// MARK: - Timespec operators and comparison

extension timespec {
    
    @inlinable internal func adding(_ rhs: timespec) -> timespec {
        
        let nsRaw = rhs.tv_nsec + self.tv_nsec
        
        let ns = nsRaw % 1_000_000_000
        
        let s = self.tv_sec + rhs.tv_sec + (nsRaw / 1_000_000_000)
        
        return timespec(tv_sec: s, tv_nsec: ns)
        
    }
    
    @inlinable internal func subtracting(_ rhs: timespec) -> timespec {
        
        let nsRaw = self.tv_nsec - rhs.tv_nsec
        
        if nsRaw >= 0 {
            
            let ns = nsRaw % 1_000_000_000
            
            let s = self.tv_sec - rhs.tv_sec + (nsRaw / 1_000_000_000)
            
            return timespec(tv_sec: s, tv_nsec: ns)
            
        } else {
            
            // roll under
            
            let ns = 1_000_000_000 - (-nsRaw % 1_000_000_000)
            
            let s = self.tv_sec - rhs.tv_sec - 1 - (-nsRaw / 1_000_000_000)
            
            return timespec(tv_sec: s, tv_nsec: ns)
            
        }
        
    }
    
}

extension timespec {
    
    @inlinable internal func isEqual(to rhs: Self) -> Bool {
        
        self.tv_sec == rhs.tv_sec &&
            self.tv_nsec == rhs.tv_nsec
        
    }
    
}

extension timespec {
    
    @inlinable internal func isLess(than rhs: timespec) -> Bool {
        
        if self.tv_sec < rhs.tv_sec { return true }
        if self.tv_sec > rhs.tv_sec { return false }
        
        // seconds equate; now test nanoseconds
        
        if self.tv_nsec < rhs.tv_nsec { return true }
        
        return false
        
    }
    
    @inlinable internal func isGreater(than rhs: timespec) -> Bool {
        
        !self.isLess(than: rhs)
        
    }
    
}

#endif
