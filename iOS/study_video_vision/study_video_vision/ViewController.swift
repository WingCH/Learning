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
        // Do any additional setup after loading the view.
        guard let videoURL = Bundle.main.url(forResource: "RPReplay_Final1701175542", withExtension: "MP4") else {
            print("無法找到視頻文件")
            return
        }

        let images: [UIImage] = Array(extractFrames(from: videoURL, eachSecond: 1))

        generateFeaturePrints(for: images) { [weak self] featurePrints in
            self?.compareFeaturePrints(featurePrints)
        }
    }

    func extractFrames(from videoURL: URL, eachSecond: TimeInterval) -> [UIImage] {
        let asset = AVAsset(url: videoURL)
        let assetGenerator = AVAssetImageGenerator(asset: asset)
        assetGenerator.appliesPreferredTrackTransform = true
        assetGenerator.requestedTimeToleranceBefore = .zero
        assetGenerator.requestedTimeToleranceAfter = .zero

        var frames: [UIImage] = []
        var currentTime: Float64 = 0
        let duration = CMTimeGetSeconds(asset.duration)

        while currentTime < duration {
            let cmTime = CMTimeMakeWithSeconds(currentTime, preferredTimescale: 600)
            do {
                let imageRef = try assetGenerator.copyCGImage(at: cmTime, actualTime: nil)
                frames.append(UIImage(cgImage: imageRef))
            } catch {
                print("Error extracting frame at \(currentTime) seconds")
            }
            currentTime += eachSecond
        }
        return frames
    }

    func generateFeaturePrints(for images: [UIImage], completion: @escaping ([VNFeaturePrintObservation?]) -> Void) {
        var featurePrints: [VNFeaturePrintObservation?] = []

        let group = DispatchGroup()
        for image in images {
            group.enter()
            guard let cgImage = image.cgImage else {
                featurePrints.append(nil)
                group.leave()
                continue
            }

            let request = VNGenerateImageFeaturePrintRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
                print("request.results: \(request.results)")
                featurePrints.append(request.results?.first as? VNFeaturePrintObservation)
            } catch {
                featurePrints.append(nil)
                print("Error generating feature print: \(error)")
            }
            group.leave()
        }

        group.notify(queue: .main) {
            completion(featurePrints)
        }
    }

    func compareFeaturePrints(_ featurePrints: [VNFeaturePrintObservation?]) {
        for i in 0 ..< (featurePrints.count - 1) {
            guard let print1 = featurePrints[i], let print2 = featurePrints[i + 1] else {
                continue
            }
            var distance = Float(0)
            try? print1.computeDistance(&distance, to: print2)
            print("Distance between image \(i) and \(i + 1): \(distance)")
        }
    }
}
