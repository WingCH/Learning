//
//  ViewController.swift
//  study_scrollview
//
//  Created by Wing on 2/8/2023.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    var scrollView: UIScrollView!
    var customView: UIView!
    var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customView = UIView()
        customView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 2000)
        customView.backgroundColor = .blue
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.delegate = self
        scrollView.contentSize = customView.bounds.size
        
        scrollView.addSubview(customView)
        view.addSubview(scrollView)
        scrollView.contentInsetAdjustmentBehavior = .never
        
        // will trigger `scrollViewDidScroll`
        scrollView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        scrollView.contentOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
        // same
//        scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: false)

        
        button = UIButton(type: .system)
        button.frame = CGRect(x: 20, y: 40, width: 100, height: 30)
        button.setTitle("Add Inset", for: .normal)
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc func buttonClicked() {
        // will not trigger `scrollViewDidScroll`
        scrollView.contentInset = UIEdgeInsets(top: scrollView.contentInset.top + 200,
                                               left: 0,
                                               bottom: 0,
                                               right: 0)
    }
    
    // 一開始會 trigger左3次
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll")
        // 指示用戶是否已觸摸內容以啟動滾動。
        print("isTracking: \(scrollView.isTracking)")
        // 指示用戶是否已開始滾動內容。
        print("isDragging: \(scrollView.isDragging)")
        // 指示用戶抬起手指後內容是否在滾動視圖中移動。
        print("isDecelerating: \(scrollView.isDecelerating)")
    }
}
