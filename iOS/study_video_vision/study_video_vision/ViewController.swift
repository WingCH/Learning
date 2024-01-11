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
        // 初始化視圖控制器時的設定
        guard let videoURL = Bundle.main.url(forResource: "RPReplay_Final1701175542", withExtension: "MP4") else {
            print("無法找到視頻文件")
            return
        }
        // 異步任務：從視頻中提取幀，生成特徵列印並進行比較
        Task {
            let images = try await extractFrames(from: videoURL, eachSecond: 1)
            let featurePrints = await generateFeaturePrints(for: images)
            self.compareFeaturePrints(featurePrints)
            print(images)
        }
    }

    // 從視頻URL異步提取每秒的幀
    func extractFrames(from videoURL: URL, eachSecond: TimeInterval) async throws -> [UIImage] {
        let asset = AVAsset(url: videoURL)
        let durationTime = try await asset.load(.duration)
        let durationSeconds = CMTimeGetSeconds(durationTime)

        // 根據視頻持續時間和每秒間隔提取幀
        return await extractFramesUsingDuration(asset: asset, duration: durationSeconds, eachSecond: eachSecond)
    }

    // 使用AVAssetImageGenerator從AVAsset中提取幀
    func extractFramesUsingDuration(asset: AVAsset, duration: Double, eachSecond: TimeInterval) async -> [UIImage] {
        let assetGenerator = AVAssetImageGenerator(asset: asset)
        assetGenerator.appliesPreferredTrackTransform = true // 確保圖像方向正確
        assetGenerator.requestedTimeToleranceBefore = .zero
        assetGenerator.requestedTimeToleranceAfter = .zero

        var frames: [UIImage] = []
        var currentTime: Float64 = 0

        // 循環遍歷每個時間點，提取對應的幀
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

    // 為每個圖像幀生成特徵列印
    func generateFeaturePrints(for images: [UIImage]) async -> [VNFeaturePrintObservation?] {
        var featurePrints = [VNFeaturePrintObservation?](repeating: nil, count: images.count)

        // 使用並行任務處理每個圖像
        await withTaskGroup(of: (Int, VNFeaturePrintObservation?).self) { group in
            for (index, image) in images.enumerated() {
                guard let cgImage = image.cgImage else {
                    featurePrints[index] = nil
                    continue
                }

                // 為每個圖像創建一個異步任務以處理特徵列印
                group.addTask {
                    let result = await self.processImage(cgImage)
                    return (index, result)
                }
            }

            // 收集所有異步任務的結果
            for await (index, result) in group {
                featurePrints[index] = result
            }
        }

        return featurePrints
    }

    // 處理單個圖像，生成特徵列印
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

    // 比較相鄰圖像幀的特徵列印之間的距離
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
