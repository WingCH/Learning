import AVFoundation
import XCTest

final class PlaybackConfigurationTests: XCTestCase {
    func testDefaultMediaURLIsHTTPSVideoURL() {
        let url = PlaybackConfiguration.defaultMediaURL

        XCTAssertEqual(url.scheme, "https")
        XCTAssertFalse(url.absoluteString.isEmpty)
        XCTAssertTrue(url.pathExtension == "mp4" || url.pathExtension == "m3u8")
    }

    func testDefaultPlayerAllowsExternalVideoPlayback() {
        let player = PlaybackConfiguration.makeDefaultPlayer()
        let asset = player.currentItem?.asset as? AVURLAsset

        XCTAssertEqual(asset?.url, PlaybackConfiguration.defaultMediaURL)
        XCTAssertTrue(player.allowsExternalPlayback)
        XCTAssertTrue(player.usesExternalPlaybackWhileExternalScreenIsActive)
    }
}
