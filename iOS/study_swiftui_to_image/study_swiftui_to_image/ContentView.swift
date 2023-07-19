//
//  ContentView.swift
//  study_swiftui_to_image
//
//  Created by Wing on 18/7/2023.
//

import SwiftUI

// https://www.hackingwithswift.com/quick-start/swiftui/how-to-convert-a-swiftui-view-to-an-image
extension View {
    /*
     看起來你正在嘗試使用 Swift 的 SwiftUI 來創建一個 View 的快照，並把它轉化為一個 UIImage。從你的問題來看，當 View 的高度過大時，生成的圖像會顯示為全白。

     這可能是因為 `drawHierarchy(in:afterScreenUpdates:)` 方法有一定的性能和資源限制，當試圖繪制的視圖超過一定尺寸時，可能會出現無法正確渲染的情況。

     不過，你可以試試一種可能的解決方案：把長的視圖分割為多個小視圖，分別截圖，然後再把這些圖片拼接起來。這種方法可能會複雜一些，但在處理大尺寸視圖時能有更好的表現。以下是實現這種方法的一個基本示例：

     ```swift
     extension UIView {
         func snapshot() -> UIImage {
             let totalSize = self.bounds.size
             UIGraphicsBeginImageContextWithOptions(totalSize, false, UIScreen.main.scale)

             guard let context = UIGraphicsGetCurrentContext() else {
                 return UIImage()
             }

             for y in stride(from: CGFloat(0), to: self.bounds.size.height, by: UIScreen.main.bounds.height) {
                 context.saveGState()
                 context.translateBy(x: 0, y: -y)
                 self.layer.render(in: context)
                 context.restoreGState()
             }

             let image = UIGraphicsGetImageFromCurrentImageContext()!
             UIGraphicsEndImageContext()
             return image
         }
     }
     ```

     這個代碼的關鍵點在於它使用 `stride(from:to:by:)` 函數來分割視圖，每次處理一屏的高度，然後再通過 `context.translateBy(x:y:)` 函數來移動畫布，使每一部分都可以被正確地渲染。

     請注意，這只是一個基本示例，你可能需要根據你的具體需求對其進行一些調整。
     */
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.frame = CGRect(origin: CGPoint(x: 0, y: 0.0001), size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

struct ContentView: View {
    var longVStack: some View {
        VStack {
            ForEach(0 ..< 46) { _ in
                Text("Hello, world!")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1)))
            }
        }
    }

    var body: some View {
        VStack {
            ScrollView {
                longVStack
            }
            Button("Save to image") {
                let image = longVStack.edgesIgnoringSafeArea(.all).snapshot()
                // tested in iOS 15 16, 1-45 成功，但45以上就會白晒
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
