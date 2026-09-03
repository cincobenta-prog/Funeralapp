//
//  TributeMediaPlayerView.swift
//  DigiTributeCore
//
//  Native audio and video player for memorial tributes in macOS & iOS.
//

import SwiftUI
import AVFoundation

public struct TributeMediaPlayerView: View {
    public let tribute: Tribute
    public let topic: Topic?

    @State private var isPlaying: Bool = false
    @State private var playbackProgress: Double = 0.0

    public init(tribute: Tribute, topic: Topic? = nil) {
        self.tribute = tribute
        self.topic = topic
    }

    public var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 6) {
                if let t = topic {
                    Text("“\(t.questionText)”")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Text("Tribute from \(tribute.contributorName) (\(tribute.relationshipType))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Player Canvas
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.85))
                    .frame(height: 180)

                VStack(spacing: 14) {
                    if tribute.mediaType == .videoAndAudio || tribute.mediaType == .video {
                        Image(systemName: "video.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white.opacity(0.8))
                        Text("Video Tribute Recording")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    } else {
                        // Audio Waveform Visualizer
                        HStack(spacing: 4) {
                            ForEach(0..<18, id: \.self) { index in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(isPlaying ? Color.accentColor : Color.gray.opacity(0.5))
                                    .frame(width: 5, height: isPlaying ? CGFloat.random(in: 10...50) : 12)
                            }
                        }
                        .frame(height: 50)

                        Text("Voice Tribute Audio")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }

                    Button {
                        isPlaying.toggle()
                    } label: {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(Color.accentColor)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
}
