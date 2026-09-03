//
//  MediaRecordingStudioView.swift
//  DigiTributeCore
//
//  Studio interface for Voice-Only (Audio waveform) and Video & Audio recording.
//  Includes prompt teleprompter, timer, live waveform visualizer, and submission flow.
//

import SwiftUI

public struct MediaRecordingStudioView: View {
    public let topic: Topic?
    public let relationship: RelationshipType
    public let onComplete: (Tribute) -> Void
    public let onBack: () -> Void

    @State private var mediaMode: TributeMediaType = .voiceOnly
    @State private var isRecording: Bool = false
    @State private var recordingDuration: Int = 0
    @State private var hasRecorded: Bool = false
    @State private var contributorName: String = ""
    @State private var contributorEmail: String = ""
    @State private var timer: Timer?

    public init(
        topic: Topic?,
        relationship: RelationshipType,
        onComplete: @escaping (Tribute) -> Void,
        onBack: @escaping () -> Void
    ) {
        self.topic = topic
        self.relationship = relationship
        self.onComplete = onComplete
        self.onBack = onBack
    }

    public var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Button {
                    onBack()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Prompts")
                    }
                    .font(.footnote)
                }
                .buttonStyle(.plain)
                Spacer()

                // Mode Picker (Voice Only vs Video & Audio)
                Picker("Media Mode", selection: $mediaMode) {
                    Text("🎙️ Voice Only").tag(TributeMediaType.voiceOnly)
                    Text("📹 Video & Audio").tag(TributeMediaType.videoAndAudio)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 260)
            }
            .padding(.horizontal)

            // Prompt Teleprompter Card
            VStack(spacing: 8) {
                if let t = topic {
                    if let pillar = t.pillar {
                        HStack(spacing: 4) {
                            Image(systemName: pillar.icon)
                            Text(pillar.rawValue)
                        }
                        .font(.caption2.weight(.bold))
                        .foregroundColor(Color.accentColor)
                    }

                    Text("“\(t.questionText)”")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    Text("Share Your Freely Spoken Memory")
                        .font(.headline)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.secondary.opacity(0.08)))
            .padding(.horizontal)

            // Recording Canvas
            if mediaMode == .voiceOnly {
                voiceRecordingCanvas
            } else {
                videoRecordingCanvas
            }

            // Contributor Info & Submit
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    TextField("Your Name", text: $contributorName)
                        .textFieldStyle(.roundedBorder)

                    TextField("Your Email", text: $contributorEmail)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)

                Button {
                    submitTribute()
                } label: {
                    Text("Submit Memory for Family")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.accentColor)
                .disabled(contributorName.isEmpty || !hasRecorded)
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Voice Only Canvas
    private var voiceRecordingCanvas: some View {
        VStack(spacing: 20) {
            // Live Waveform Visualizer
            HStack(spacing: 4) {
                ForEach(0..<24, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(isRecording ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(
                            width: 6,
                            height: isRecording ? CGFloat.random(in: 12...65) : 10
                        )
                        .animation(isRecording ? .easeInOut(duration: 0.15).repeatForever() : .default, value: isRecording)
                }
            }
            .frame(height: 80)
            .padding(.vertical, 10)

            // Timer display
            Text(formattedDuration(recordingDuration))
                .font(.system(size: 28, weight: .semibold, design: .monospaced))
                .foregroundColor(isRecording ? .red : .primary)

            // Record / Stop Button
            Button {
                toggleRecording()
            } label: {
                ZStack {
                    Circle()
                        .stroke(isRecording ? Color.red.opacity(0.3) : Color.accentColor.opacity(0.3), lineWidth: 4)
                        .frame(width: 74, height: 74)

                    Circle()
                        .fill(isRecording ? Color.red : Color.accentColor)
                        .frame(width: 58, height: 58)

                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                }
            }
            .buttonStyle(.plain)

            Text(isRecording ? "Recording your voice... Tap to finish." : (hasRecorded ? "Recording saved. Tap to re-record." : "Tap to start voice recording"))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.secondary.opacity(0.04)))
        .padding(.horizontal)
    }

    // MARK: - Video & Audio Canvas
    private var videoRecordingCanvas: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.85))
                .frame(height: 240)

            VStack(spacing: 12) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.7))

                Text(isRecording ? "Recording Video · \(formattedDuration(recordingDuration))" : "Camera Preview Ready")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)

                Button {
                    toggleRecording()
                } label: {
                    Label(isRecording ? "Stop Video" : "Start Video Recording", systemImage: isRecording ? "stop.circle.fill" : "record.circle")
                        .font(.body.weight(.semibold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(isRecording ? Color.red : Color.white)
                        .foregroundColor(isRecording ? .white : .black)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }

    private func toggleRecording() {
        if isRecording {
            isRecording = false
            hasRecorded = true
            timer?.invalidate()
            timer = nil
        } else {
            isRecording = true
            recordingDuration = 0
            hasRecorded = false
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                recordingDuration += 1
            }
        }
    }

    private func submitTribute() {
        let tribute = Tribute(
            subjectId: UUID(),
            topicId: topic?.id,
            contributorName: contributorName,
            contributorEmail: contributorEmail,
            relationshipType: relationship.rawValue,
            mediaType: mediaMode,
            status: .submitted
        )
        onComplete(tribute)
    }

    private func formattedDuration(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
