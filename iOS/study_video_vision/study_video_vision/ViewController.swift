//
//  ViewController.swift
//  study_video_vision
//
//  Created by Wing on 28/11/2023.
//

import AVFoundation
import UIKit
import Vision

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        // Set up the view controller on initialization
        guard let videoURL = Bundle.main.url(forResource: "RPReplay_Final1701175542", withExtension: "MP4") else {
            print("Video file not found")
            return
        }
        Task {
            let result = try? await VisionVideoFeaturePrintHelper.processVideoAndComputeFeaturePrints(videoURL: videoURL)
            print("result: \(result)")
        }
        print("----")
    }
}
