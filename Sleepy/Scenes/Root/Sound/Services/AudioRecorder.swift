// Copyright (c) 2022 Sleepy.

import AVFoundation
import Combine
import FirebaseAnalytics
import Foundation
import SettingsKit
import SwiftUI

class AudioRecorder: NSObject, ObservableObject {
    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    var audioRecorder: AVAudioRecorder?

    @Published var recordings = [Recording]()

    var isRecording = false {
        didSet {
            self.objectWillChange.send(self)
        }
    }

    override init() {
        super.init()
        self.fetchRecordings()
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
            AVEncoderAudioQualityKey: NSNumber(value: Int32(AVAudioQuality.medium.rawValue)),
        ]

        do {
            self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            if let audioRecorder = audioRecorder {
                audioRecorder.record()
                self.isRecording = true
            }
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
        guard let audioRecorder = audioRecorder else {
            return
        }
        audioRecorder.stop()
        self.isRecording = false
        self.fetchRecordings()
    }

    func fetchRecordings() {
        self.recordings.removeAll()

        let fileManager = FileManager.default
        let documentDirectory = self.getDocumentsDirectory()
        let directoryContents = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
        for audio in directoryContents {
            let recording = Recording(fileURL: audio, createdAt: FileHelper.creationDateForLocalFilePath(for: audio))
            self.recordings.append(recording)
        }

        self.recordings.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending })

        self.objectWillChange.send(self)
    }

    func removeAllRecordings() {
        for recording in self.recordings {
            try? FileManager.default.removeItem(at: recording.fileURL)
        }
        self.fetchRecordings()
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
