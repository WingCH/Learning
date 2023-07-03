import UIKit
import PlaygroundSupport

// 创建一个 UIImageView
let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))

// 如果你有一张图片，你可以像这样将其加载到 imageView
// 请确保 Playground 有访问图片资源的权限
imageView.image = #imageLiteral(resourceName: "iShot_2023-07-02_11.13.53.png")

// 翻转并移动变换
let flipTransform = CGAffineTransform(scaleX: 1, y: -1)
//let translateTransform = flipTransform.translatedBy(x: 0, y: -100)

// 给 imageView 应用变化
imageView.transform = flipTransform

// 展示 imageView
PlaygroundPage.current.liveView = imageView
