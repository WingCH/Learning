import UIKit

public extension UIImage {
    enum ResizeMode {
        /// Scale the image such that it will fit (equal or small than) the specified size
        case fit
        /// Scale the image such that it will fill (equal or larger than) the specified size
        case fill
    }

    func resized(targetSize: CGSize, resizeMode: ResizeMode? = nil) -> UIImage {
        let size = self.size

        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        switch resizeMode {
        case .fit:
            if widthRatio > heightRatio {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            }
        case .fill:
            if widthRatio > heightRatio {
                newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            } else {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            }
        case .none:
            newSize = targetSize
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? self
    }

    func resizeWithCoreImage(targetSize: CGSize, resizeMode: ResizeMode? = nil) -> UIImage {
        let size = self.size

        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        switch resizeMode {
        case .fit:
            if widthRatio > heightRatio {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            }
        case .fill:
            if widthRatio > heightRatio {
                newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            } else {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            }
        case .none:
            newSize = targetSize
        }

        guard let cgImage = self.cgImage else { return self }
        let ciImage = CIImage(cgImage: cgImage)

        let scale = newSize.height / size.height
        let aspectRatio = newSize.width / (size.width * scale)

        let filter = CIFilter(name: "CILanczosScaleTransform")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(scale, forKey: kCIInputScaleKey)
        filter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)

        guard let outputImage = filter.outputImage else { return self }
        let context = CIContext(options: nil)
        guard let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else { return self }

        return UIImage(cgImage: outputCGImage)
    }
}

let originalImage = #imageLiteral(resourceName: "36044.original.jpg")

print(originalImage.size)

// 計算時間
let startTime = Date()
let resizedImage = originalImage.resized(targetSize: CGSize(width: 1024, height: 1024), resizeMode: .fit)
let endTime = Date()
let timeInterval: Double = endTime.timeIntervalSince(startTime)
print(resizedImage.size)
print("Time: \(timeInterval) seconds")

// 計算時間
let startTime2 = Date()
let resizedImage2 = originalImage.resizeWithCoreImage(targetSize: CGSize(width: 1024, height: 1024), resizeMode: .fit)
let endTime2 = Date()
let timeInterval2: Double = endTime2.timeIntervalSince(startTime2)
print(resizedImage2.size)
print("Time: \(timeInterval2) seconds")
