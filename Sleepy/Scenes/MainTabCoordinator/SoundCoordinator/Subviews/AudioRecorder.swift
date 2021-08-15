//
//  AudioRecorder.swift
//  Sleepy
//
//  Created by Никита Казанцев on 14.08.2021.
//

import Foundation
import SwiftUI
import AVFoundation
import Combine

class AudioRecorder: NSObject, ObservableObject {

    override init() {
        super.init()
        fetchRecordings()
    }

    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()

    var audioRecorder: AVAudioRecorder!

    @Published var recordings = [Recording]()

    var recording = false {
        didSet {
            objectWillChange.send(self)
        }
    }

    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()

        if recordingSession.recordPermission != .granted {
            recordingSession.requestRecordPermission { (isGranted) in
                if !isGranted {
                    //fatalError("You must allow audio recording for this demo to work")
                    return
                }
            }
        }

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session")
        }

        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentPath.appendingPathComponent("\(Date().toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss")).m4a")

        let bitrate = UserDefaults.standard.getInt(forKey: .soundBitrate) ?? 12000
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: bitrate,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.record()

            recording = true
        } catch {
            print("Could not start recording")
        }
    }

    func stopRecording() {
        audioRecorder.stop()
        recording = false

        fetchRecordings()
    }

    func fetchRecordings() {
        recordings.removeAll()

        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryContents = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
        for audio in directoryContents {
            let recording = Recording(fileURL: audio, createdAt: FileHelper.creationDateForLocalFilePath(for: audio))
            recordings.append(recording)
        }

        recordings.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending})

        objectWillChange.send(self)
    }
}
