//
//  Blurrer.swift
//  Blur
//
//  Created by Xavi Moll on 05/01/2019.
//  Copyright © 2019 xmollv. All rights reserved.
//

import UIKit
import CoreImage
import Foundation

protocol Blurrer {
    func blur(_ image: UIImage, amount: Float) -> UIImage?
}

final class _Blurrer: Blurrer {
    
    private let blurFilter = CIFilter(name: "CIGaussianBlur")
    private let context = CIContext()
    
    func blur(_ image: UIImage, amount: Float) -> UIImage? {
        
        // Make sure that we've been able to create the filter, otherwise return with no op
        guard let blurFilter = self.blurFilter else { return nil }
        
        // Transform the passed image into a CIImage maintaining the orientation
        let ciImage = CIImage(image: image)?.oriented(forExifOrientation: self.imageOrientationToTiffOrientation(image.imageOrientation))
        
        // Set that image as the input for the filter
        blurFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        // Set the desired blur
        blurFilter.setValue(amount / 2, forKey: kCIInputRadiusKey)
        
        // Grab the output after setting the result
        guard let outputImage = blurFilter.outputImage else { return nil }
        
        // Grab the cgImage with the correct size to avoid it being cropped
        guard let cgImage = self.context.createCGImage(outputImage, from: ciImage?.extent ?? outputImage.extent) else { return nil }
        
        // Return the new UIImage
        return UIImage(cgImage: cgImage)
    }
}

private extension _Blurrer {
    func imageOrientationToTiffOrientation(_ value: UIImage.Orientation) -> Int32 {
        switch (value) {
        case .up:
            return 1
        case .down:
            return 3
        case .left:
            return 8
        case .right:
            return 6
        case .upMirrored:
            return 2
        case .downMirrored:
            return 4
        case .leftMirrored:
            return 5
        case .rightMirrored:
            return 7
        }
    }
}
