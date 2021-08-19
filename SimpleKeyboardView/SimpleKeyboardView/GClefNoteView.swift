//
//  GClefNoteView.swift
//
//  Created by shout@claudiu.mn on 2021.08.16.

import UIKit

struct Pitch: Comparable {
    let note: Note // FIXME: Maybe should be a natural
    let octave: UInt
    
    var natural: Natural {
        switch note {
        case .c: return .c
        case .cSharp: return .c
        case .d: return .d
        case .dSharp: return .d
        case .e: return .e
        case .f: return .f
        case .fSharp: return .f
        case .g: return .g
        case .gSharp: return .g
        case .a: return .a
        case .aSharp: return .a
        case .b: return .b
        }
    }
    
    var isAccidental: Bool { return natural.rawValue != self.note }
    
    // FIME: What about octave > UInt.max?
    func adding(semitoneCount: UInt) -> Pitch {
        if semitoneCount == 0 { return self }
        
        let notes = Note.allCases
        
        var index = notes.firstIndex(of: note)!
        var octave = Int(octave)
        
        var count = semitoneCount
        while count != 0 {
            index += 1
            if index >= notes.count {
                index = 0
                octave += 1
            }
            count -= 1
        }
        
        return Pitch(note: notes[index], octave: UInt(octave))
    }
    
    // FIXME: What about octave < 0?
    func naturalDistance(from pitch: Pitch) -> Int {
        let naturalSelf = Pitch(note: natural.rawValue, octave: octave)
        
        if naturalSelf == pitch { return 0 }
        
        let naturals = Natural.allCases

        var originOctave = Int(pitch.octave)
        var originNaturalIndex = naturals.firstIndex(of: pitch.natural)!
        
        var currentPitch = pitch
        var naturalDistance = 0
        
        if naturalSelf < pitch {
            while naturalSelf != currentPitch {
                originNaturalIndex -= 1
                if originNaturalIndex < 0 {
                    originNaturalIndex = naturals.count - 1
                    originOctave -= 1
                }
                let natural = naturals[originNaturalIndex]
                currentPitch = Pitch(note: natural.rawValue,
                                     octave: UInt(originOctave))
                naturalDistance -= 1
            }
            return naturalDistance
        }
        
        while naturalSelf != currentPitch {
            originNaturalIndex += 1
            if originNaturalIndex >= naturals.count {
                originNaturalIndex = 0
                originOctave += 1
            }
            let natural = naturals[originNaturalIndex]
            currentPitch = Pitch(note: natural.rawValue,
                                 octave: UInt(originOctave))
            naturalDistance += 1
        }
        return naturalDistance
    }
    
    static func < (lhs: Pitch, rhs: Pitch) -> Bool {
        if lhs.octave < rhs.octave { return true }
        
        if lhs.octave == rhs.octave {
            return lhs.note.rawValue < rhs.note.rawValue
        }
        
        return false
    }
    
    static func == (lhs: Pitch, rhs: Pitch) -> Bool {
        return lhs.octave == rhs.octave && lhs.note == rhs.note
    }
}

private struct PitchRange {
    let start: Pitch
    let end: Pitch
    
    init(start: Pitch, end: Pitch) {
        if start > end {
            fatalError("Start pitch must be less than or equal to end pitch!")
        }
        
        self.start = start
        self.end = end
    }
    
    func contains(pitch: Pitch) -> Bool {
        return pitch >= start && pitch <= end;
    }
}

class GClefNoteView: UIView {
    private let clefPitch = Pitch(note: .g, octave: 4)
    private let clefLineIndex = 1 // Counting from bottom
    private let lineCount = 5
    let startPitch = Pitch(note: .b, octave: 3)
    private let naturalRange = NaturalRange(start: .b, length: 14)
    private var pitch: Pitch?
    
    private weak var lineContainer: UIView!
    private weak var noteContainer: UIView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        changeTint()
    }
    
    private func changeTint() {
        for line in lineContainer.subviews {
            line.backgroundColor = tintColor
        }
        
        for note in noteContainer.subviews {
            note.backgroundColor = tintColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let minDim = min(bounds.width, bounds.height)
        let lineWidth: CGFloat = minDim * 0.015
        
        let height = bounds.height
        let spaceHeight = height / 8
        let lastLineIndexInBothDirections = 2
        
        for line in lineContainer.subviews { line.removeFromSuperview() }
        
        for i in 0...lastLineIndexInBothDirections {
            let centerY = lineContainer.bounds.height / 2
            
            if i == 0 {
                let line = UIView()
                line.translatesAutoresizingMaskIntoConstraints = false
                line.backgroundColor = tintColor
                lineContainer.addSubview(line)
                line.frame = CGRect(x: 0,
                                    y: centerY - lineWidth / 2,
                                    width: lineContainer.bounds.width,
                                    height: lineWidth)
            } else {
                let lineAbove = UIView()
                lineAbove.translatesAutoresizingMaskIntoConstraints = false
                lineAbove.backgroundColor = tintColor
                lineContainer.addSubview(lineAbove)
                lineAbove.frame = CGRect(x: 0,
                                         y: centerY - CGFloat(i) * spaceHeight - lineWidth / 2,
                                         width: lineContainer.bounds.width,
                                         height: lineWidth)
                
                let lineBelow = UIView()
                lineBelow.translatesAutoresizingMaskIntoConstraints = false
                lineBelow.backgroundColor = tintColor
                lineContainer.addSubview(lineBelow)
                lineBelow.frame = CGRect(x: 0,
                                         y: centerY + CGFloat(i) * spaceHeight - lineWidth / 2,
                                         width: lineContainer.bounds.width,
                                         height: lineWidth)
            }
        }
        
        for note in noteContainer.subviews { note.removeFromSuperview() }
        
        guard let pitch = pitch else { return }
        
        let range = PitchRange(start: startPitch,
                               end: Pitch(note: naturalRange.start.rawValue,
                                          octave: 5))
        
        let naturalLength = abs(range.start.naturalDistance(from: range.end))
        let stepHeight = height / CGFloat(naturalLength + 2)
        
        let noteHeight = spaceHeight
        let noteWidth = spaceHeight * 1.5
        
        let note = OvalView()
        note.backgroundColor = tintColor
        note.translatesAutoresizingMaskIntoConstraints = false
        noteContainer.addSubview(note)
        
        let distance = -CGFloat(pitch.naturalDistance(from: range.end))
        note.frame = CGRect(x: bounds.width / 2 - noteWidth / 2,
                            y: distance * stepHeight,
                            width: noteWidth,
                            height: noteHeight)
        
        if pitch.isAccidental {
            let sharp = SharpView()
            sharp.translatesAutoresizingMaskIntoConstraints = false
            sharp.tintColor = tintColor
            noteContainer.addSubview(sharp)
            
            let sharpHeight = noteHeight * 2.7
            let sharpWidth = sharpHeight * 0.367
            
            sharp.center = CGPoint(x: note.center.x - noteWidth,
                                   y: note.center.y)
            sharp.bounds = CGRect(x: 0,
                                  y: 0,
                                  width: sharpWidth,
                                  height: sharpHeight)
        }
        
        var hLineCount = helperLineCount(for: pitch)
        if hLineCount == 0 { return }
        
        let dir = hLineCount > 0 ? -1 : 1
        
        while hLineCount != 0 {
            let line = UIView()
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = tintColor
            noteContainer.addSubview(line)
            
            let center = CGPoint(x: note.center.x,
                                 y: noteContainer.bounds.height / 2 - CGFloat(hLineCount) * spaceHeight + CGFloat(lastLineIndexInBothDirections * dir) * spaceHeight)
            
            line.center = center
            line.bounds = CGRect(x: 0,
                                 y: 0,
                                 width: noteWidth * 1.5,
                                 height: lineWidth)
            
            hLineCount += dir
        }
    }
    
    /// Positive for lines above, negative for lines below
    func helperLineCount(for pitch: Pitch) -> Int {
        let naturalPitch = Pitch(note: pitch.natural.rawValue,
                                 octave: pitch.octave)
        
        let pitchOnBottomLine = Pitch(note: .e, octave: 4)
        let pitchOnTopLine = Pitch(note: .f, octave: 5)
        
        if naturalPitch < pitchOnBottomLine {
            return naturalPitch.naturalDistance(from: pitchOnBottomLine) / 2
        }
        
        if naturalPitch > pitchOnTopLine {
            return naturalPitch.naturalDistance(from: pitchOnTopLine) / 2
        }
        
        return 0
    }
    
    private func setUp() {
        let cont = UIView()
        cont.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cont)
        
        cont.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        cont.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        cont.topAnchor.constraint(equalTo: topAnchor).isActive = true
        cont.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        lineContainer = cont
        
        let notecont = UIView()
        notecont.translatesAutoresizingMaskIntoConstraints = false
        addSubview(notecont)
        
        notecont.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        notecont.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        notecont.topAnchor.constraint(equalTo: topAnchor).isActive = true
        notecont.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        noteContainer = notecont
        
        noteContainer.clipsToBounds = true
    }
    
    func show(pitch: Pitch) {
        let range = PitchRange(start: startPitch,
                               end: Pitch(note: naturalRange.start.rawValue,
                                          octave: 5))
        
        if !range.contains(pitch: pitch) { fatalError("Pitch out of range!") }
        
        self.pitch = pitch
        
        setNeedsLayout()
        layoutIfNeeded()
    }
}
