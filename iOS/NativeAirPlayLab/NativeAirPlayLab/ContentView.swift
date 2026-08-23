import AVKit
import Combine
import SwiftUI

struct ContentView: View {
    @State private var player = PlaybackConfiguration.makeDefaultPlayer()
    @State private var isPlaying = false

    // 關鍵診斷：route picker 顯示已選中裝置時，仍要用這個值確認 AVPlayer 是否真的進入外部影片播放。
    @State private var isExternalPlaybackActive = false
    @State private var routeSummary = MediaPlaybackConfiguration.currentRouteSummary()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                NativeVideoPlayer(player: player)
                    .frame(minHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                HStack(spacing: 20) {
                    Button(isPlaying ? "Pause" : "Play") {
                        if isPlaying {
                            player.pause()
                        } else {
                            player.play()
                        }
                        isPlaying.toggle()
                    }
                    .buttonStyle(.borderedProminent)

                    AirPlayRoutePicker()
                        .frame(width: 48, height: 48)
                        .accessibilityLabel("AirPlay")
                }

                VStack(alignment: .leading, spacing: 8) {
                    // "AirPlay video active" 是成功訊號；只看到 MacBook 被選中仍不足以證明影片已投放。
                    Label(
                        isExternalPlaybackActive ? "AirPlay video active" : "AirPlay video not active",
                        systemImage: isExternalPlaybackActive ? "airplayvideo.circle.fill" : "airplayvideo"
                    )
                    .foregroundStyle(isExternalPlaybackActive ? .green : .secondary)

                    Text("Current route: \(routeSummary)")
                        .foregroundStyle(.secondary)
                }
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Test stream")
                        .font(.headline)
                    Text(PlaybackConfiguration.defaultMediaURL.absoluteString)
                        .font(.footnote)
                        .textSelection(.enabled)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }
            .padding()
            .navigationTitle("Native AirPlay Lab")
            .onAppear {
                isExternalPlaybackActive = player.isExternalPlaybackActive
                routeSummary = MediaPlaybackConfiguration.currentRouteSummary()
            }
            // 監聽 AVPlayer 的外部播放狀態，這是判斷 AirPlay video 是否真正生效的 ground truth。
            .onReceive(player.publisher(for: \.isExternalPlaybackActive).receive(on: RunLoop.main)) { isActive in
                isExternalPlaybackActive = isActive
            }
            // route change 只用作輔助診斷，方便分辨目前輸出仍是 iPhone、Mac，或其他 AirPlay 裝置。
            .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)) { _ in
                routeSummary = MediaPlaybackConfiguration.currentRouteSummary()
            }
        }
    }
}

#Preview {
    ContentView()
}
