import UIKit
import Vision

let image = #imageLiteral(resourceName: "IMG_1219-min.PNG")

Task {
    do {
        let (text, taggedImage) = try await recognizeText(from: image)
        print(text)
        taggedImage
    } catch {
        print(error)
    }
}

func recognizeText(from image: UIImage) async throws -> (String, UIImage) {
    guard let cgImage = image.cgImage else {
        fatalError("Can't convert UIImage to CGImage")
    }

    let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    let request = VNRecognizeTextRequest()

    request.recognitionLevel = .accurate
    request.recognitionLanguages = ["zh-Hant", "zh-Hans", "en-US"]
    request.usesLanguageCorrection = false

    var recognisedText = ""
    var taggedImage = image
    do {
        try requestHandler.perform([request])

        guard let observations = request.results else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No text recognised"])
        }

        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else {
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No candidate"])
            }
            recognisedText += topCandidate.string + "\n"
        }

        if let a = drawRectanglesAroundText(on: image, recognizedText: observations) {
            taggedImage = a
        }
    } catch {
        throw error
    }
    return (recognisedText, taggedImage)
}

func drawRectanglesAroundText(on image: UIImage, recognizedText: [VNRecognizedTextObservation]) -> UIImage? {
    guard let cgImage = image.cgImage else {
        fatalError("Can't convert UIImage to CGImage")
    }

    let scale = UIScreen.main.scale
    let orientation = UIDevice.current.orientation

    UIGraphicsBeginImageContextWithOptions(image.size, true, scale)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }
    context.interpolationQuality = .none
    image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

    recognizedText.forEach { observation in
        context.saveGState()
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -image.size.height)

        let transform = VNImageRectForNormalizedRect(observation.boundingBox, Int(image.size.width), Int(image.size.height))
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(2.0)
        context.stroke(transform)
        context.restoreGState()
    }

    let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return drawnImage
}
