//
//  ViewController.swift
//  study_rxswift
//
//  Created by Wing CHAN on 21/6/2023.
//

import UIKit
import RxSwift

// https://www.notion.so/wingchhk/DisposeBag-Cancellable-2cdad0971a234a8d9ff37c4f23d565f5?pvs=4
// 無加 DisposeBag & Cancellable, 都會subscriber 到, 但可能用leak
class ViewController: UIViewController {
    let subject = PublishSubject<Int>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        subject.subscribe(onNext: { value in
            print("Received value: \(value)")
        })
        
        subject.onNext(1)
        subject.onNext(2)
        subject.onNext(3)
        
        // Do any additional setup after loading the view.
    }


}

