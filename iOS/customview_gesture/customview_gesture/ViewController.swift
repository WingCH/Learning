//
//  ViewController.swift
//  customview_gesture
//
//  Created by Wing CHAN on 27/4/2023.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let customView = CustomView(frame: CGRect(x: 50, y: 50, width: 200, height: 100))
        customView.backgroundColor = .gray
            
        customView.onTapView = {
            print("CustomView was tapped!")
        }
            
        customView.onTapButton = {
            print("Button was tapped!")
        }
            
        view.addSubview(customView)
    }
}

class CustomView: UIView {
    let label = UILabel()
    let controlView = UIControl()
    
    var onTapView: (() -> Void)?
    var onTapButton: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.text = "Hello World!"
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: frame.width, height: 30)
        addSubview(label)
        
        controlView.backgroundColor = .blue
        controlView.frame = CGRect(x: 0, y: 40, width: frame.width, height: 30)
        controlView.addTarget(self, action: #selector(onButtonTap), for: .touchUpInside)
        addSubview(controlView)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onViewTap))
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.delegate = self
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onViewTap() {
        onTapView?()
    }
    
    @objc private func onButtonTap() {
        onTapButton?()
    }
}

extension CustomView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Get the location of the touch in reference to this view.
        let touchPoint = touch.location(in: self)
        // Convert the button's bounds to this view's coordinate system.
        let controlViewFrame = controlView.convert(controlView.bounds, to: self)
        // If the touch location is within the button's frame, do not allow the gesture to continue.
        if controlViewFrame.contains(touchPoint) {
            return false
        }
        return true
    }
}
