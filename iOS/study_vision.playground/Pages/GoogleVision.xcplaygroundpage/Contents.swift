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
func analyzeImageWithGoogleVisionOCR(image: UIImage, completion: @escaping (Result<(String, UIImage?), Error>) -> Void) {
    guard let base64Image = convertImageToBase64(image: image) else {
        print("Could not convert image to base64.")
        return
    }

    let imageAnalysisRequest: [String: Any] = generateImageAnalysisRequest(with: base64Image)
    
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: imageAnalysisRequest)
        let apiURL = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=XXXXX")!
        
        var apiRequest = URLRequest(url: apiURL)
        apiRequest.httpMethod = "POST"
        apiRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        apiRequest.httpBody = jsonData
        
        let apiRequestTask = URLSession.shared.dataTask(with: apiRequest) { data, _, error in
            handleAPIResponse(data: data, error: error, completion: completion)
        }
        apiRequestTask.resume()
    } catch {
        print("Error: \(error)")
    }
}

func convertImageToBase64(image: UIImage) -> String? {
    return image.jpegData(compressionQuality: 1.0)?.base64EncodedString()
}

func generateImageAnalysisRequest(with base64Image: String) -> [String: Any] {
    return [
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
}

func handleAPIResponse(data: Data?, error: Error?, completion: @escaping (Result<(String, UIImage?), Error>) -> Void) {
    if let error = error {
        completion(.failure(error))
        return
    }

    guard let data = data else {
        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received from API"])))
        return
    }

    do {
        let googleVisionResponse = try JSONDecoder().decode(GoogleVisionResponse.self, from: data)
        let text = googleVisionResponse.responses[0].textAnnotations.map { $0.description }.joined(separator: "\n")
        
        let verticesList = googleVisionResponse.responses[0].textAnnotations.map { $0.boundingPoly.vertices }
        let rects = extractRectanglesFromVertices(verticesList: verticesList, on: image)
        let drawnImage = drawDetectedTextBoundsOnImage(image: image, with: rects)
        
        completion(.success((text, drawnImage)))
    } catch let decodeError {
        completion(.failure(decodeError))
    }
}

func extractRectanglesFromVertices(verticesList: [[GoogleVisionResponse.Response.TextAnnotation.Vertex]], on image: UIImage) -> [CGRect] {
    // Removed unnecessary 'rects' variable declaration
    return verticesList.compactMap { vertices in
        // Assume vertices are always four and form a rectangle.
        guard vertices.count == 4 else { return nil }

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

let image = #imageLiteral(resourceName: "IMG_1219-min.PNG")
analyzeImageWithGoogleVisionOCR(image: image) { result in
    switch result {
    case .success(let (text, drawnImage)):
        print(text)
        if let image = drawnImage {
            image
        } else {
            print("No image returned.")
        }
    case .failure(let error):
        print("Error: \(error)")
    }
}

