//
//  VisionVideoFeaturePrintHelper.swift
//  study_video_vision
//
//  Created by Wing on 24/3/2024.
//

import AVFoundation
import UIKit
import Vision

struct VisionVideoFeaturePrintHelper {
    static func processVideoAndComputeFeaturePrints(videoURL: URL) async throws -> ([UIImage], [Float]) {
        let images = try await extractFrames(from: videoURL, eachSecond: 1)
        let featurePrints = await generateFeaturePrints(for: images)
        let distances = compareFeaturePrints(featurePrints)
        return (images, distances)
    }

    // Asynchronously extract frames from a video URL at each second interval
    private static func extractFrames(from videoURL: URL, eachSecond: TimeInterval) async throws -> [UIImage] {
        let asset = AVAsset(url: videoURL)
        let durationTime = try await asset.load(.duration)
        let durationSeconds = CMTimeGetSeconds(durationTime)

        // Extract frames based on video duration and interval between each second
        return await extractFramesUsingDuration(asset: asset, duration: durationSeconds, eachSecond: eachSecond)
    }

    // Extract frames from an AVAsset using AVAssetImageGenerator
    private static func extractFramesUsingDuration(asset: AVAsset, duration: Double, eachSecond: TimeInterval) async -> [UIImage] {
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
                print("Error extracting frame at time \(currentTime): \(error)")
                
            }
            currentTime += eachSecond
        }
        return frames
    }

    // Generate feature prints for each image frame
    private static func generateFeaturePrints(for images: [UIImage]) async -> [VNFeaturePrintObservation?] {
        var featurePrints = [VNFeaturePrintObservation?](repeating: nil, count: images.count)

        // Process each image in parallel tasks
        await withTaskGroup(of: (Int, VNFeaturePrintObservation?).self) { group in
            for (index, image) in images.enumerated() {
                guard let cgImage = image.cgImage else {
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
    private static func processImage(_ cgImage: CGImage) async -> VNFeaturePrintObservation? {
        let request = VNGenerateImageFeaturePrintRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        return await withCheckedContinuation { continuation in
            // Offload the VNImageRequestHandler's perform operation to a background thread to prevent blocking.
            // Sometimes, perform can stall due to its synchronous nature, especially with heavy image processing tasks.
            // Running it asynchronously on a background thread helps avoid freezing the UI or the current async flow.
            DispatchQueue.global().async {
                do {
                    try handler.perform([request])
                    let observation = request.results?.first as? VNFeaturePrintObservation
                    continuation.resume(returning: observation)
                } catch {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    // Compare the distance between feature prints of adjacent image frames
    private static func compareFeaturePrints(_ featurePrints: [VNFeaturePrintObservation?]) -> [Float] {
        var distances: [Float] = []
        for i in 0 ..< (featurePrints.count - 1) {
            guard let print1 = featurePrints[i], let print2 = featurePrints[i + 1] else {
                continue
            }
            var distance = Float(0)
            try? print1.computeDistance(&distance, to: print2)
            distances.append(distance)
        }
        return distances
    }
}
