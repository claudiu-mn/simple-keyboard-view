//
//  MusicTheory.swift
//
//  Created by shout@claudiu.mn on 2021.08.16.

enum Note: UInt, CaseIterable {
    case c = 0,
         cSharp = 1,
         d = 2,
         dSharp = 3,
         e = 4,
         f = 5,
         fSharp = 6,
         g = 7,
         gSharp = 8,
         a = 9,
         aSharp = 10,
         b = 11
}

enum Natural: CaseIterable {
    case c, d, e, f, g, a, b
    
    var rawValue: Note {
        get {
            switch self {
            case .c: return .c
            case .d: return .d
            case .e: return .e
            case .f: return .f
            case .g: return .g
            case .a: return .a
            case .b: return .b
            }
        }
    }
}

private enum Sharps: CaseIterable {
    case cSharp, dSharp, fSharp, gSharp, aSharp
    
    var rawValue: Note {
        get {
            switch self {
            case .cSharp: return .cSharp
            case .dSharp: return .dSharp
            case .fSharp: return .fSharp
            case .gSharp: return .gSharp
            case .aSharp: return .aSharp
            }
        }
    }
}

struct NaturalRange {
    let start: Natural
    /// Distance from start measured in natural notes
    let length: UInt
    
    var sharpCount: UInt {
        return UInt(sharpDistribution.filter { $0 }.count)
    }
    
    var sharpDistribution: [Bool] {
        var sharps: [Bool] = []
        var whiteIndex = Natural.allCases.firstIndex(of: start)!
        
        var whiteLength = 0
        while whiteLength < length {
            let nextWhiteIndex = whiteIndex + 1
            
            if nextWhiteIndex >= Natural.allCases.count {
                whiteIndex = 0
                sharps.append(false)
            } else {
                let whiteNote = Natural.allCases[whiteIndex].rawValue
                let whiteUInt = whiteNote.rawValue
                let nextWhiteNote = Natural.allCases[nextWhiteIndex].rawValue
                let nextWhiteUInt = nextWhiteNote.rawValue
                if nextWhiteUInt - whiteUInt > 1 {
                    sharps.append(true)
                } else {
                    sharps.append(false)
                }
                whiteIndex += 1
            }
            
            whiteLength += 1
        }
        
        return sharps
    }
    
    var noteCount: UInt {
        return length + 1 + sharpCount
    }
}
