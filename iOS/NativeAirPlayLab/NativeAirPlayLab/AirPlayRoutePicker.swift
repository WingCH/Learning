import AVKit
import SwiftUI

struct AirPlayRoutePicker: UIViewRepresentable {
    static func makeConfiguredView() -> AVRoutePickerView {
        let view = AVRoutePickerView()

        // 關鍵：route picker 只負責選擇輸出裝置；這個設定會優先顯示可接收影片的 AirPlay 裝置。
        view.prioritizesVideoDevices = true
        view.tintColor = .systemBlue
        view.activeTintColor = .systemGreen
        return view
    }

    func makeUIView(context: Context) -> AVRoutePickerView {
        Self.makeConfiguredView()
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}
