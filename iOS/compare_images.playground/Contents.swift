import UIKit
import Vision



/**
 Generate Feature Print Observation for an NSImage.
 
 - Parameter nsImage: The NSImage to generate the feature print for.
 - Returns: A `VNFeaturePrintObservation` object representing the feature print of the image.
 */
func compareImages(image1: UIImage, image2: UIImage) {
    print("******")
    // 將 UIImage 轉換為 CIImage
    guard let ciImage1 = CIImage(image: image1),
          let ciImage2 = CIImage(image: image2) else {
        print(".....")
        return
    }
    
    // 創建 VNImageRequestHandler
    let handler1 = VNImageRequestHandler(ciImage: ciImage1, options: [:])
    let handler2 = VNImageRequestHandler(ciImage: ciImage2, options: [:])
    
    // 創建 VNGenerateImageFeaturePrintRequest
    let request1 = VNGenerateImageFeaturePrintRequest()
    let request2 = VNGenerateImageFeaturePrintRequest()
    
    do {
        try handler1.perform([request1])
        try handler2.perform([request2])
    } catch let error {
        print("Failed to perform request:", error)
        return
    }
    
    if let results1 = request1.results, results1.count > 0,
       let results2 = request2.results, results2.count > 0 {
        
        guard let observation1 = results1.first as? VNFeaturePrintObservation,
              let observation2 = results2.first as? VNFeaturePrintObservation else {
            print("Could not cast result to VNFeaturePrintObservation")
            return
        }
        
        // 計算相似度
        var distance = Float(0)
        try? observation1.computeDistance(&distance, to: observation2)
        
        // 使用 distance 進行後續操作
        print("Distance between images: \(distance)")
        
        
    }
}


let image1 = #imageLiteral(resourceName: "IMG_0716.PNG")
let image2 = #imageLiteral(resourceName: "IMG_0717.PNG")
let image3 = #imageLiteral(resourceName: "IMG_0718.PNG")

compareImages(image1: image1, image2: image2)

