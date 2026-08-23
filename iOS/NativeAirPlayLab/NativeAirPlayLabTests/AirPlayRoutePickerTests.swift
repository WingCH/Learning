import AVKit
import XCTest

final class AirPlayRoutePickerTests: XCTestCase {
    func testConfiguredViewUsesVideoRoutePicker() {
        let view = AirPlayRoutePicker.makeConfiguredView()

        XCTAssertEqual(view.prioritizesVideoDevices, true)
        XCTAssertEqual(view.tintColor, .systemBlue)
        XCTAssertEqual(view.activeTintColor, .systemGreen)
    }
}
