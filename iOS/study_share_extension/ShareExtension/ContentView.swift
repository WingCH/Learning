//
//  SwiftUIView.swift
//  ShareExtension
//
//  Created by Wing on 23/7/2023.
//

import SwiftUI
import Vision

struct ContentView: View {
    @EnvironmentObject var sharedData: SharedData
    var body: some View {
        switch sharedData.imageStatue {
        case .loading:
            Text("Loading...")
        case .success(let uiImage):
            // 60~80mb memory
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .onAppear {
                    Task {
                        if let textObservations = try? await recognizeText(from: uiImage) {
                            print(textObservations)
                        }
                    }
                }
        case .failure(let error):
            Text(error.localizedDescription)
        }
    }

    private func recognizeText(from image: UIImage) async throws -> [VNRecognizedTextObservation] {
        guard let cgImage = image.cgImage else {
            fatalError("Can't convert UIImage to CGImage")
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest()

        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["zh-Hant", "zh-Hans", "en-US"]
        request.usesLanguageCorrection = false

        do {
            try requestHandler.perform([request])
            guard let observations = request.results else {
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No text recognised"])
            }
            return observations
        } catch {
            throw error
        }
    }
}
