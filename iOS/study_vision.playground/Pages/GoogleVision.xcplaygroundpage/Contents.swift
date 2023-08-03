import PlaygroundSupport
import UIKit
PlaygroundPage.current.needsIndefiniteExecution = true

struct GoogleVisionResponse: Codable {
    struct Response: Codable {
        struct TextAnnotation: Codable {
            struct Vertice: Codable {
                let x: Int?
                let y: Int?
            }

            struct BoundingPoly: Codable {
                let vertices: [Vertice]
            }

            let description: String
            let boundingPoly: BoundingPoly
        }

        let textAnnotations: [TextAnnotation]
    }

    let responses: [Response]
}

func callGoogleVisionOCR(image: UIImage, completion: @escaping (Result<(String, UIImage?), Error>) -> Void) {
    guard let base64Image = image.jpegData(compressionQuality: 1.0)?.base64EncodedString() else {
        print("Could not convert image to base64.")
        return
    }

    let jsonRequest: [String: Any] = [
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

    let jsonData = try! JSONSerialization.data(withJSONObject: jsonRequest)
    let url = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=AIzaSyDuXTHCPaQm362OJSjlicGW41IQp5RYniY")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData

    let task = URLSession.shared.dataTask(with: request) { data, _, error in
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

//            let verticesList = googleVisionResponse.responses[0].textAnnotations.map { $0.boundingPoly.vertices }
            let verticesList = [googleVisionResponse.responses[0].textAnnotations.first.map({
                $0.boundingPoly.vertices
            })!]
            let drawnImage = drawRectanglesAroundText(on: image, verticesList: verticesList)

            completion(.success((text, drawnImage)))
        } catch let decodeError {
            completion(.failure(decodeError))
        }
    }
    task.resume()
}

func drawRectanglesAroundText(on image: UIImage, verticesList: [[GoogleVisionResponse.Response.TextAnnotation.Vertice]]) -> UIImage? {
    guard let cgImage = image.cgImage else {
        fatalError("Can't convert UIImage to CGImage")
    }
    
    let scale = UIScreen.main.scale
    UIGraphicsBeginImageContextWithOptions(image.size, true, scale)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }
    context.interpolationQuality = .none
    image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

    context.saveGState()
    context.scaleBy(x: 1, y: -1)
    context.translateBy(x: 0, y: -image.size.height)
    
    verticesList.forEach { vertices in
        // Assume vertices are always four and form a rectangle.
        if vertices.count == 4 {
            let upperLeft = CGPoint(x: vertices[0].x ?? 0, y: vertices[0].y ?? 0)
            let upperRight = CGPoint(x: vertices[1].x ?? 0, y: vertices[1].y ?? 0)
            let lowerRight = CGPoint(x: vertices[2].x ?? 0, y: vertices[2].y ?? 0)
            let lowerLeft = CGPoint(x: vertices[3].x ?? 0, y: vertices[3].y ?? 0)
        
            let width = upperRight.x - upperLeft.x
            let height = lowerLeft.y - upperLeft.y
            let rect = CGRect(x: upperLeft.x, y: upperLeft.y, width: width, height: height)
        
            context.setStrokeColor(UIColor.red.cgColor)
            context.setLineWidth(2.0)
            context.stroke(rect)
        }
    }
    
    context.restoreGState()
    
    let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return drawnImage
}

let image = #imageLiteral(resourceName: "IMG_1219-min.PNG")
callGoogleVisionOCR(image: image) { result in
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
