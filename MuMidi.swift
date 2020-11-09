//
//  MuMidi.swift
//  MuseSky
//
//  Created by warren on 9/19/20.
//  Copyright © 2020 Muse. All rights reserved.
//

import Foundation
import AudioKit
import AVFoundation
import Tr3

class MuLog {
    static func print(_ icon: String,_ msg: String) {
        Swift.print(icon + msg, terminator: " ")
    }
}
class MuAudio {

    public static let shared = MuAudio()
    let engine = AudioEngine()

    public func test() {

        let oscillator = Oscillator()
        engine.output = oscillator
        do {
            try engine.start()
            oscillator.start()
            oscillator.frequency = 440
            sleep(4)
            oscillator.stop()
        }
        catch {
            print(error)
        }

    }
}

class MidiTr3 {

    var noteOnNum˚: Tr3?
    var noteOnVelo˚: Tr3?
    var noteOnChan˚: Tr3?
    var noteOnPort˚: Tr3?
    var noteOnTime˚: Tr3?

    var noteOffNum˚: Tr3?
    var noteOffVelo˚: Tr3?
    var noteOffChan˚: Tr3?
    var noteOffPort˚: Tr3?
    var noteOffTime˚: Tr3?

    var ctrlNum˚: Tr3?
    var ctrlVal˚: Tr3?
    var ctrlChan˚: Tr3?
    var ctrlPort˚: Tr3?
    var ctrlTime˚: Tr3?

    var afterNum˚: Tr3?
    var afterVal˚: Tr3?
    var afterChan˚: Tr3?
    var afterPort˚: Tr3?
    var afterTime˚: Tr3?

    var pitchVal˚: Tr3?
    var pitchChan˚: Tr3?
    var pitchPort˚: Tr3?
    var pitchTime˚: Tr3?
    var programNum˚: Tr3?
    var programChan˚: Tr3?
    var programPort˚: Tr3?
    var programTime˚: Tr3?

    public var setOptions: Tr3SetOptions = [.activate]

    init(_ root: Tr3, io: String) {
        bindTr3(root, io: io)
    }

    func bindTr3(_ root: Tr3, io: String) {

        if  let sky = root.findPath("sky"),
            let midi = sky.findPath("midi"),
            let io = midi.findPath(io), // input or output
            let note = io.findPath("note"),
            let noteOn = note.findPath("on"),
            let noteOff = note.findPath("off"),
            let ctrl = io.findPath("ctrl"),
            let after = io.findPath("after"),
            let pitch = io.findPath("pitch"),
            let program = io.findPath("program") {

            noteOnNum˚ = noteOn.findPath("num")
            noteOnVelo˚ = noteOn.findPath("velo")
            noteOnChan˚ = noteOn.findPath("chan")
            noteOnPort˚ = noteOn.findPath("port")
            noteOnTime˚ = noteOn.findPath("time")

            noteOffNum˚ = noteOff.findPath("num")
            noteOffVelo˚ = noteOff.findPath("velo")
            noteOffChan˚ = noteOff.findPath("chan")
            noteOffPort˚ = noteOff.findPath("port")
            noteOffTime˚ = noteOff.findPath("time")

            ctrlNum˚ = ctrl.findPath("num")
            ctrlVal˚ = ctrl.findPath("val")
            ctrlChan˚ = ctrl.findPath("chan")
            ctrlPort˚ = ctrl.findPath("port")
            ctrlTime˚ = ctrl.findPath("time")

            afterNum˚ = after.findPath("num")
            afterVal˚ = after.findPath("val")
            afterChan˚ = after.findPath("chan")
            afterPort˚ = after.findPath("port")
            afterTime˚ = after.findPath("time")

            pitchVal˚ = pitch.findPath("val")
            pitchChan˚ = pitch.findPath("chan")
            pitchPort˚ = pitch.findPath("port")
            pitchTime˚ = pitch.findPath("time")

            programNum˚ = program.findPath("num")
            programChan˚ = program.findPath("chan")
            programPort˚ = program.findPath("port")
            programTime˚ = program.findPath("time")
        }
    }

    func noteOn(_ num: MIDINoteNumber,
                _ velo: MIDIVelocity,
                _ chan: MIDIChannel,
                _ port: MIDIUniqueID?,
                _ time: MIDITimeStamp) {

        noteOnNum˚?.setVal(Int(num), setOptions)
        noteOnVelo˚?.setVal(Int(velo), setOptions)
        noteOnChan˚?.setVal(Int(chan), setOptions)
        noteOnPort˚?.setVal(port ?? 0, setOptions)
        noteOnTime˚?.setVal(time, setOptions)
    }

    func noteOff(_ num: MIDINoteNumber,
                 _ velo: MIDIVelocity,
                 _ chan: MIDIChannel,
                 _ port: MIDIUniqueID?,
                 _ time: MIDITimeStamp) {

        noteOffNum˚?.setVal(Int(num), setOptions)
        noteOffVelo˚?.setVal(Int(velo), setOptions)
        noteOffChan˚?.setVal(Int(chan), setOptions)
        noteOffPort˚?.setVal(port ?? 0, setOptions)
        noteOffTime˚?.setVal(time, setOptions)
    }

    func controller(_ ctrl: MIDIByte,
                    _ val: MIDIVelocity,
                    _ chan: MIDIChannel,
                    _ port: MIDIUniqueID?,
                    _ time: MIDITimeStamp) {

        ctrlNum˚?.setVal(Int(ctrl), setOptions)
        ctrlVal˚?.setVal(Int(val), setOptions)
        ctrlChan˚?.setVal(Int(chan), setOptions)
        ctrlPort˚?.setVal(port ?? 0, setOptions)
        ctrlTime˚?.setVal(time, setOptions)
    }

    func aftertouch(_ num: MIDINoteNumber,
                    _ val: MIDIByte,
                    _ chan: MIDIChannel,
                    _ port: MIDIUniqueID?,
                    _ time: MIDITimeStamp) {

        afterNum˚?.setVal(Int(num), setOptions)
        afterVal˚?.setVal(Int(chan), setOptions)
        afterChan˚?.setVal(Int(chan), setOptions)
        afterPort˚?.setVal(port ?? 0, setOptions)
        afterTime˚?.setVal(time, setOptions)
    }

    func aftertouch(_ val: MIDIByte,
                    _ chan: MIDIChannel,
                    _ port: MIDIUniqueID?,
                    _ time: MIDITimeStamp) {

        afterNum˚?.setVal(Int(0), setOptions)
        afterVal˚?.setVal(Int(val), setOptions)
        afterChan˚?.setVal(Int(chan), setOptions)
        afterPort˚?.setVal(port ?? 0, setOptions)
        afterTime˚?.setVal(time, setOptions)
    }

    func pitchWheel(_ val: MIDIWord,
                    _ chan: MIDIChannel,
                    _ port: MIDIUniqueID?,
                    _ time: MIDITimeStamp) {

        pitchVal˚?.setVal(Int(val), setOptions)
        pitchChan˚?.setVal(Int(chan), setOptions)
        pitchPort˚?.setVal(port ?? 0, setOptions)
        pitchTime˚?.setVal(time, setOptions)
    }

    func programChange(_ num: MIDIByte,
                       _ chan: MIDIChannel,
                       _ port: MIDIUniqueID?,
                       _ time: MIDITimeStamp) {

        programNum˚?.setVal(Int(num), setOptions)
        programChan˚?.setVal(Int(chan), setOptions)
        programPort˚?.setVal(port ?? 0, setOptions)
        programTime˚?.setVal(time, setOptions)
    }
}

class MuMidiListener: MIDIListener {

    var receive: MidiTr3!

    init(_ root: Tr3) {
        receive = MidiTr3(root, io: "input")
    }

    func note(_ note: MIDINoteNumber, _ velocity: MIDIVelocity) -> String {
        let names = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
        let octave = Int(note / 12)
        let note = Int(note % 12)
        let name = names[note]
        return "\(name)\(octave):\(velocity)"
    }

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel,
                            portID: MIDIUniqueID?,
                            offset: MIDITimeStamp) {

        MuLog.print("♪", note(noteNumber, velocity))
        receive.noteOn(noteNumber, velocity, channel, portID, offset)
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                             channel: MIDIChannel,
                             portID: MIDIUniqueID?,
                             offset: MIDITimeStamp) {

        MuLog.print("∅", note(noteNumber, velocity))
        receive.noteOn(noteNumber, velocity, channel, portID, offset)
    }

    func receivedMIDIController(_ controller: MIDIByte,
                                value: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                offset: MIDITimeStamp) {

        MuLog.print("🎚", "\(controller):\(value)")
        receive.controller(controller, value, channel, portID, offset)
    }

    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                offset: MIDITimeStamp) {

        MuLog.print("👆", note(noteNumber, pressure))
        receive.aftertouch(noteNumber, channel, portID, offset)
    }

    func receivedMIDIAftertouch(_ pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                offset: MIDITimeStamp) {
        MuLog.print("👆", "\(channel):\(pressure)")
        receive.aftertouch(pressure, channel, portID, offset)
    }

    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                offset: MIDITimeStamp) {
        MuLog.print("◯⃝", "\(pitchWheelValue)")
        receive.pitchWheel(pitchWheelValue, channel, portID, offset)
    }

    func receivedMIDIProgramChange(_ program: MIDIByte,
                                   channel: MIDIChannel,
                                   portID: MIDIUniqueID?,
                                   offset: MIDITimeStamp) {
        MuLog.print("⚙️", "\(program)")
        receive.programChange(program, channel, portID, offset)
    }

    func receivedMIDISystemCommand(_ data: [MIDIByte],
                                   portID: MIDIUniqueID?,
                                   offset: MIDITimeStamp) {
        MuLog.print("🆇", " \(data)\n")
    }
    
    func receivedMIDISetupChange() {
    }

    func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {
         MuLog.print("🅟", " \(propertyChangeInfo)\n")
    }

    func receivedMIDINotification(notification: MIDINotification) {
        MuLog.print("🅼", " \(notification)\n")
    }
}

class MuMidi {

    public static let shared = MuMidi()

    public func test(root: Tr3 ) {
        let midi = MIDI.sharedInstance
        let listener = MuMidiListener(root)
        midi.openInput()
        midi.addListener(listener)
    }
}
