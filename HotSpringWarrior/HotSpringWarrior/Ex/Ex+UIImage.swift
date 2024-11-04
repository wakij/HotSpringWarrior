//
//  Ex+UIImage.swift
//  HotSpringWarrior
//
//  Created by tomoshigewakita on 2024/09/06.
//

import UIKit
import Accelerate

extension UIImage {
//    全てのピクセル値が0か255の2値になっていることを前提としています。
    func calcAlphaRatio() -> Float {
        let image = self
        let cgImage = image.cgImage!
        let colorSpace = cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB()
        let unmanagedColorSpace = Unmanaged.passUnretained(colorSpace)
        // 1. CGImageからvImage_Bufferを作成
        var format = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            colorSpace: unmanagedColorSpace,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue),
            version: 0,
            decode: nil,
            renderingIntent: cgImage.renderingIntent
        )

        var sourceBuffer = vImage_Buffer()
        defer {
            free(sourceBuffer.data)
        }

        let _ = vImageBuffer_InitWithCGImage(
            &sourceBuffer,
            &format,
            nil,
            cgImage,
            vImage_Flags(kvImageNoFlags)
        )

        // 2. アルファチャンネル用のvImage_Bufferを作成
        let pixelCount = Int(sourceBuffer.width * sourceBuffer.height)
        let bytesPerRow = Int(sourceBuffer.width)

        var alphaBuffer = vImage_Buffer()
        alphaBuffer.width = sourceBuffer.width
        alphaBuffer.height = sourceBuffer.height
        alphaBuffer.rowBytes = bytesPerRow
        alphaBuffer.data = malloc(pixelCount * MemoryLayout<UInt8>.size)
        defer {
            free(alphaBuffer.data)
        }

        // 3. アルファチャンネルを抽出
        let _ = vImageExtractChannel_ARGB8888(
            &sourceBuffer,
            &alphaBuffer,
            0, // アルファチャンネルのインデックス（premultipliedFirstではインデックス0）
            vImage_Flags(kvImageNoFlags)
        )
        let alphaPointer = alphaBuffer.data.assumingMemoryBound(to: UInt8.self)
        var alphaFloat = [Float](repeating: 0, count: pixelCount)
        vDSP_vfltu8(alphaPointer, 1, &alphaFloat, 1, vDSP_Length(pixelCount))

        var sumvDSP: Float = 0.0
        vDSP_sve(alphaFloat, 1, &sumvDSP, vDSP_Length(alphaFloat.count))
        
        return Float(sumvDSP) / Float(255) / Float(pixelCount)
    }
}
