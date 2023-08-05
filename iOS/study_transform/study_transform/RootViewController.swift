//
//  RootViewController.swift
//  study_transform
//
//  Created by Wing on 5/8/2023.
//

import UIKit

class ViewController: UIViewController {

    var sampleView: UIView!
    var button: UIButton!
    var state: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // 創建視圖並設置在中心位置
        sampleView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        sampleView.backgroundColor = UIColor.red
        sampleView.center = self.view.center
        self.view.addSubview(sampleView)
        
        // 創建按鈕
        button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        button.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 200)
        button.backgroundColor = UIColor.blue
        button.setTitle("Click me", for: .normal)
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        self.view.addSubview(button)
    }

    @objc func buttonClicked() {
        // 根據 state 的值決定需要進行哪種轉換
        let transform: CGAffineTransform
        switch state {
        case 0: // 平移
            transform = CGAffineTransform(translationX: 100, y: 200)
        case 1: // 縮放
            transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        case 2: // 旋轉
            transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
        default: // 回到原始狀態
            transform = .identity
            state = -1 // 減一，因為後面有 state += 1 的操作
        }
        
        // 執行動畫
        self.sampleView.transform = .identity
        UIView.animate(withDuration: 2.0) {
      
            self.sampleView.transform = transform
        }

        // 更新 state 的值
        state += 1
    }
}
