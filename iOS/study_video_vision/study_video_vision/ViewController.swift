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
        // Set up the view controller on initialization
        guard let videoURL = Bundle.main.url(forResource: "RPReplay_Final1701175542", withExtension: "MP4") else {
            print("Video file not found")
            return
        }
        // Asynchronous task: Extract frames from video, generate feature prints, and compare them
        Task {
            let images = try await extractFrames(from: videoURL, eachSecond: 1)
            let featurePrints = await generateFeaturePrints(for: images)
            self.compareFeaturePrints(featurePrints)
            print(images)
        }
    }

    // Asynchronously extract frames from a video URL at each second interval
    func extractFrames(from videoURL: URL, eachSecond: TimeInterval) async throws -> [UIImage] {
        let asset = AVAsset(url: videoURL)
        let durationTime = try await asset.load(.duration)
        let durationSeconds = CMTimeGetSeconds(durationTime)

        // Extract frames based on video duration and interval between each second
        return await extractFramesUsingDuration(asset: asset, duration: durationSeconds, eachSecond: eachSecond)
    }

    // Extract frames from an AVAsset using AVAssetImageGenerator
    func extractFramesUsingDuration(asset: AVAsset, duration: Double, eachSecond: TimeInterval) async -> [UIImage] {
        let assetGenerator = AVAssetImageGenerator(asset: asset)
        assetGenerator.appliesPreferredTrackTransform = true // Ensure the image orientation is correct
        assetGenerator.requestedTimeToleranceBefore = .zero
        assetGenerator.requestedTimeToleranceAfter = .zero

        var frames: [UIImage] = []
        var currentTime: Float64 = 0

        // Iterate through each time point to extract corresponding frame
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

    // Generate feature prints for each image frame
    func generateFeaturePrints(for images: [UIImage]) async -> [VNFeaturePrintObservation?] {
        var featurePrints = [VNFeaturePrintObservation?](repeating: nil, count: images.count)

        // Process each image in parallel tasks
        await withTaskGroup(of: (Int, VNFeaturePrintObservation?).self) { group in
            for (index, image) in images.enumerated() {
                guard let cgImage = image.cgImage else {
                    featurePrints[index] = nil
                    continue
                }

                // Create an asynchronous task for processing feature print for each image
                group.addTask {
                    let result = await self.processImage(cgImage)
                    return (index, result)
                }
            }

            // Collect results from all asynchronous tasks
            for await (index, result) in group {
                featurePrints[index] = result
            }
        }

        return featurePrints
    }

    // Process a single image to generate a feature print
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

    // Compare the distance between feature prints of adjacent image frames
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
