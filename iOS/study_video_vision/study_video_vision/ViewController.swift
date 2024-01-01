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
        Task {
            let images = try await extractFrames(from: videoURL, eachSecond: 1)
            let featurePrints = await generateFeaturePrints(for: images)
            self.compareFeaturePrints(featurePrints)
            print(images)
        }
    }

    func extractFrames(from videoURL: URL, eachSecond: TimeInterval) async throws -> [UIImage] {
        let asset = AVAsset(url: videoURL)
        let durationTime = try await asset.load(.duration)
        let durationSeconds = CMTimeGetSeconds(durationTime)

        return await extractFramesUsingDuration(asset: asset, duration: durationSeconds, eachSecond: eachSecond)
    }

    func extractFramesUsingDuration(asset: AVAsset, duration: Double, eachSecond: TimeInterval) async -> [UIImage] {
        let assetGenerator = AVAssetImageGenerator(asset: asset)
        assetGenerator.appliesPreferredTrackTransform = true
        assetGenerator.requestedTimeToleranceBefore = .zero
        assetGenerator.requestedTimeToleranceAfter = .zero

        var frames: [UIImage] = []
        var currentTime: Float64 = 0

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

    func generateFeaturePrints(for images: [UIImage]) async -> [VNFeaturePrintObservation?] {
        var featurePrints = [VNFeaturePrintObservation?](repeating: nil, count: images.count)

        await withTaskGroup(of: (Int, VNFeaturePrintObservation?).self) { group in
            for (index, image) in images.enumerated() {
                guard let cgImage = image.cgImage else {
                    featurePrints[index] = nil
                    continue
                }

                group.addTask {
                    let result = await self.processImage(cgImage)
                    return (index, result)
                }
            }

            for await (index, result) in group {
                featurePrints[index] = result
            }
        }

        return featurePrints
    }

    private func processImage(_ cgImage: CGImage) async -> VNFeaturePrintObservation? {
        let request = VNGenerateImageFeaturePrintRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        return await withCheckedContinuation { continuation in
            do {
                try handler.perform([request])
                let observation = request.results?.first as? VNFeaturePrintObservation
                continuation.resume(returning: observation)
            } catch {
                print("Error generating feature print: \(error)")
                continuation.resume(returning: nil)
            }
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
