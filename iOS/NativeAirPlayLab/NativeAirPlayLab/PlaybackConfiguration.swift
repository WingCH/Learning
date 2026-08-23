import AVFoundation

enum PlaybackConfiguration {
    static let defaultMediaURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!

    static func makeDefaultPlayer() -> AVPlayer {
        let player = AVPlayer(url: defaultMediaURL)

        // 關鍵：選中 AirPlay route 不等於播放器會外放；AVPlayer 必須明確允許 external playback。
        player.allowsExternalPlayback = true

        // 有外部螢幕或 AirPlay video route 時，讓同一個 player item 自動切到外部播放。
        player.usesExternalPlaybackWhileExternalScreenIsActive = true
        return player
    }
}
