import PlaygroundSupport
import UIKit
PlaygroundPage.current.needsIndefiniteExecution = true

struct GoogleVisionResponse: Codable {
    struct Response: Codable {
        struct TextAnnotation: Codable {
            struct Vertex: Codable {
                let x: CGFloat?
                let y: CGFloat?
            }

            struct BoundingPoly: Codable {
                let vertices: [Vertex]
            }

            let description: String
            let boundingPoly: BoundingPoly
        }

        let textAnnotations: [TextAnnotation]
    }

    let responses: [Response]
}

// Function name and variable names are more descriptive and consistent now
func analyzeImageWithGoogleVisionOCR(image: UIImage) async throws -> (String, UIImage?) {
    guard let base64Image = convertImageToBase64(image: image) else {
        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to base64."])
    }

    let imageAnalysisRequest: [String: Any] = {
        [
            "requests": [
                [
                    "image": [
                        "content": base64Image
                    ],
                    "features": [
                        [
                            "type": "TEXT_DETECTION"
                        ]
                    ]
                ]
            ]
        ]
    }()
    let jsonData = try JSONSerialization.data(withJSONObject: imageAnalysisRequest)
    let apiURL = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=XXX")!

    var apiRequest = URLRequest(url: apiURL)
    apiRequest.httpMethod = "POST"
    apiRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    apiRequest.httpBody = jsonData

    let (data, _) = try await URLSession.shared.data(for: apiRequest)

    let googleVisionResponse = try JSONDecoder().decode(GoogleVisionResponse.self, from: data)
    let text = googleVisionResponse.responses[0].textAnnotations.map { $0.description }.joined(separator: "\n")

    let verticesList = googleVisionResponse.responses[0].textAnnotations.map { $0.boundingPoly.vertices }
    let rects = extractRectanglesFromVertices(verticesList: verticesList, on: image)
    let drawnImage = drawDetectedTextBoundsOnImage(image: image, with: rects)

    return (text, drawnImage)
}

func convertImageToBase64(image: UIImage) -> String? {
    return image.jpegData(compressionQuality: 1.0)?.base64EncodedString()
}

func extractRectanglesFromVertices(verticesList: [[GoogleVisionResponse.Response.TextAnnotation.Vertex]], on image: UIImage) -> [CGRect] {
    // Removed unnecessary 'rects' variable declaration
    return verticesList.compactMap { vertices in
        // Assume vertices are always four and form a rectangle.
        guard vertices.count == 4 else { return nil }
        // 在畫矩形時，我們需要特別注意的是，Google Vision API回傳的坐標系統是以圖像左上角為原點，向右為 x 正向，向下為 y 正向。而在 iOS 中，繪製圖形的時候，坐標系統是以左上角為原點，向右為 x 正向，向上為 y 正向。
        let upperLeft = CGPoint(x: vertices[0].x ?? 0, y: image.size.height - (vertices[0].y ?? 0))
        let upperRight = CGPoint(x: vertices[1].x ?? 0, y: image.size.height - (vertices[1].y ?? 0))
        let lowerRight = CGPoint(x: vertices[2].x ?? 0, y: image.size.height - (vertices[2].y ?? 0))
        let lowerLeft = CGPoint(x: vertices[3].x ?? 0, y: image.size.height - (vertices[3].y ?? 0))

        let width = upperRight.x - upperLeft.x
        let height = upperLeft.y - lowerLeft.y
        return CGRect(x: upperLeft.x, y: lowerLeft.y, width: width, height: height)
    }
}

func drawDetectedTextBoundsOnImage(image: UIImage, with rects: [CGRect]) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }

    context.interpolationQuality = .none
    image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

    context.saveGState()
    context.scaleBy(x: 1, y: -1)
    context.translateBy(x: 0, y: -image.size.height)

    rects.forEach { rect in
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(5.0)
        context.stroke(rect)
    }

    context.restoreGState()

    let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return drawnImage
}

// Usage

let image = #imageLiteral(resourceName: "IMG_1219-min.PNG")
Task {
    do {
        let (text, drawnImage) = try await analyzeImageWithGoogleVisionOCR(image: image)
        print(text)
        if let image = drawnImage {
            // do something with the image
            image
        } else {
            print("No image returned.")
        }
    } catch {
        print("Error: \(error)")
    }
}
