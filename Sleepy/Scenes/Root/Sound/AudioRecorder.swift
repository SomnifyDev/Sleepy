//
//  AudioRecorder.swift
//  Sleepy
//
//  Created by Никита Казанцев on 14.08.2021.
//

import AVFoundation
import Combine
import FirebaseAnalytics
import Foundation
import SettingsKit
import SwiftUI

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

    func startRecording() -> Bool {
        FirebaseAnalytics.Analytics.logEvent("Sounds_recordingDidStart", parameters: nil)

        let recordingSession = AVAudioSession.sharedInstance()

        self.requestPermissions(recordingSession)

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default, policy: .default, options: .defaultToSpeaker)

            try recordingSession.setActive(true)
        } catch {
            FirebaseAnalytics.Analytics.logEvent("Sounds_sessionError", parameters: [
                "error": "Failed to set up recording session",
            ])
            return false
        }

        let audioFilename = self.getDocumentsDirectory().appendingPathComponent("\(Date().toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss")).wav")

        let bitrate = UserDefaults.standard.integer(forKey: SleepySettingsKeys.soundBitrate.rawValue)
        let settings = [
            AVFormatIDKey: NSNumber(value: Int32(kAudioFormatLinearPCM)),
            AVSampleRateKey: NSNumber(value: Float(bitrate)),
            AVNumberOfChannelsKey: NSNumber(value: 1),
            AVEncoderAudioQualityKey: NSNumber(value: Int32(AVAudioQuality.medium.rawValue))
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.record()
            recording = true
        } catch {
            FirebaseAnalytics.Analytics.logEvent("Sounds_sessionError", parameters: [
                "error": "Could not start recording",
            ])
            return false
        }

        return true
    }

    func stopRecording() {
        FirebaseAnalytics.Analytics.logEvent("Sounds_recordingDidEnd", parameters: nil)
        audioRecorder.stop()
        recording = false

        fetchRecordings()
    }

    func fetchRecordings() {
        recordings.removeAll()

        let fileManager = FileManager.default
        let documentDirectory = self.getDocumentsDirectory()
        let directoryContents = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
        for audio in directoryContents {
            let recording = Recording(fileURL: audio, createdAt: FileHelper.creationDateForLocalFilePath(for: audio))
            recordings.append(recording)
        }

        recordings.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending })

        objectWillChange.send(self)
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func requestPermissions(_ recordingSession: AVAudioSession, completion: ((Bool) -> Void)? = nil) {
        if recordingSession.recordPermission != .granted {
            recordingSession.requestRecordPermission { isGranted in
                FirebaseAnalytics.Analytics.logEvent("Sounds_permission", parameters: [
                    "granded": isGranted,
                ])
                completion?(isGranted)
            }
        }
    }
}
