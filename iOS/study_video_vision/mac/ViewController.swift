//
//  ViewController.swift
//  mac
//
//  Created by Wing on 29/3/2024.
//

import Cocoa
import AppKit

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // backgroundColor
        view.layer?.backgroundColor = NSColor.red.cgColor
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

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

