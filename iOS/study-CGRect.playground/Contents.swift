import UIKit

var greeting = "Hello, playground"

let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
// 移位
let rect1 = rect.offsetBy(dx: 10, dy: 10)
// 正數 => 縮細
let rect2 = rect.insetBy(dx: 1, dy: 1)
// 負數 => 放大
let rect3 = rect.insetBy(dx: -1, dy: -1)

