import AVFoundation
import XCTest

final class MediaPlaybackConfigurationTests: XCTestCase {
    func testMediaPlaybackUsesLongFormVideoRouting() {
        XCTAssertEqual(MediaPlaybackConfiguration.audioSessionCategory, .playback)
        XCTAssertEqual(MediaPlaybackConfiguration.audioSessionMode, .moviePlayback)
        XCTAssertEqual(MediaPlaybackConfiguration.routeSharingPolicy, .longFormVideo)
        XCTAssertEqual(MediaPlaybackConfiguration.initialRouteSharingPolicyPlistValue, "LongFormVideo")
    }
}
