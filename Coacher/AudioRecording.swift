//
//  AudioRecording.swift
//  Coacher
//
//  Created by Rebecca Clarke on 9/1/25.
//

import Foundation
import SwiftData

@Model
final class AudioRecording {
    @Attribute(.unique) var id: UUID
    var date: Date
    var audioURL: URL
    var transcription: String
    var type: CravingType?
    var duration: TimeInterval
    
    init(audioURL: URL, transcription: String, type: CravingType? = nil, duration: TimeInterval = 0) {
        self.id = UUID()
        self.date = Date()
        self.audioURL = audioURL
        self.transcription = transcription
        self.type = type
        self.duration = duration
    }
}
