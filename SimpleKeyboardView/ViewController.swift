//
//  ViewController.swift
//
//  Created by shout@claudiu.mn on 2021.08.16.

import UIKit

class ViewController: UIViewController {
    private weak var keyboardView: KeyboardView!
    private weak var noteView: GClefNoteView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyRange = NaturalRange(start: .c, length: 9)
        let keyboard = KeyboardView()
        keyboard.translatesAutoresizingMaskIntoConstraints = false
        keyboard.delegate = self
        keyboard.range = keyRange
        view.addSubview(keyboard)
        
        keyboard.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        keyboard.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        keyboard.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        keyboard.heightAnchor.constraint(equalTo: view.heightAnchor,
                                         multiplier: 0.5,
                                         constant: 0).isActive = true
        keyboardView = keyboard

        let noteView = GClefNoteView()
        noteView.backgroundColor = .white
        noteView.tintColor = .black
        noteView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noteView)
        
        noteView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        noteView.bottomAnchor.constraint(equalTo: keyboard.topAnchor).isActive = true
        noteView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noteView.widthAnchor.constraint(equalTo: noteView.heightAnchor,
                                        multiplier: 2).isActive = true
        
        self.noteView = noteView
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let insets = view.safeAreaInsets
        let minimum: CGFloat = 20
        let constant = max(insets.right, minimum)
        
        for constraint in view.constraints {
            if constraint.firstAnchor == keyboardView.leadingAnchor {
                constraint.constant = constant
            } else if constraint.firstAnchor == keyboardView.bottomAnchor ||
                        constraint.firstAnchor == keyboardView.trailingAnchor {
                constraint.constant = -constant
            } else if constraint.firstAnchor == noteView.bottomAnchor {
                constraint.constant = -minimum
            } else if constraint.firstAnchor == noteView.topAnchor {
                constraint.constant = max(insets.top, minimum)
            }
        }
    }
    
    @objc private func didTapHomeButton() { dismiss(animated: true) }
}

extension ViewController: KeyboardViewDelegate {
    
    func didReleaseKey(at index: UInt, in keyboardView: KeyboardView) {  }
    
    func didPressKey(at index: UInt, in keyboardView: KeyboardView) {
        let diff: UInt = 1 // because note view starts at B3 and keyboard at C4
        let pitch = noteView.startPitch.adding(semitoneCount: index + diff)
        noteView.show(pitch: pitch)
    }
}
