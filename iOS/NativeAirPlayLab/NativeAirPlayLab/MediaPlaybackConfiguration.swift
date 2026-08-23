import AVFoundation

enum MediaPlaybackConfiguration {
    static let audioSessionCategory: AVAudioSession.Category = .playback
    static let audioSessionMode: AVAudioSession.Mode = .moviePlayback

    // 關鍵：longFormVideo 會向系統表明這是影片播放 session，不是一般音訊 route。
    static let routeSharingPolicy: AVAudioSession.RouteSharingPolicy = .longFormVideo
    static let initialRouteSharingPolicyPlistValue = "LongFormVideo"

    static func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()

        do {
            // 關鍵：在播放前啟用 playback + moviePlayback + longFormVideo，
            // AirPlay picker 才會和 AVPlayer 以影片播放 route 協同工作。
            try session.setCategory(
                audioSessionCategory,
                mode: audioSessionMode,
                policy: routeSharingPolicy,
                options: []
            )
            try session.setActive(true)
        } catch {
            assertionFailure("Failed to configure AVAudioSession: \(error)")
        }
    }

    static func currentRouteSummary() -> String {
        // 這是診斷用途：route 名稱只代表系統目前音訊輸出，不保證影片已經 external playback。
        let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
        guard !outputs.isEmpty else {
            return "No active audio route"
        }

        return outputs
            .map { "\($0.portName) (\($0.portType.rawValue))" }
            .joined(separator: ", ")
    }
}
