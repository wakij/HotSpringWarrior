//
//  CleanProgressCalculator.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/11/05.
//
import MapKit
import UIKit
import Accelerate
///清掃進捗状況の計算
///イベント領域: S1
///清掃した領域: S2
///イベント領域を含む最小の矩形: U
///求めたい割合: S2/S1 = (S2/U) / (S1/U)
///アルファ値を見ることで計算している


class CleanProgressCalculator {
//    縦横の最大
    let maxLength: Double = 300
    
    func calculate(targetArea: Area, userTrajectory: [CLLocation], eventCircles: [MKCircle]) -> Double {
        let eventBoundary = targetArea.boundary
        let eventBoundaryPolygon = MKPolygon(coordinates: eventBoundary.map({ $0.coordinate }), count: eventBoundary.count)
        let eventBoundaryRenderer = MKPolygonRenderer(polygon: eventBoundaryPolygon)
        let eventBoundaryPath = eventBoundaryRenderer.path!
        let eventBoundaryMapRect = targetArea.boundingMapRect
        
        let routePolyline = MKPolyline(coordinates: userTrajectory.map({ $0.coordinate }), count: userTrajectory.count)
        let routePolylineRenderer = ErasePolylineRenderer(polyline: routePolyline)
        guard let routePath = routePolylineRenderer.path else { return 0 }
        let routeMapRect = routePolyline.boundingMapRect
        
        let ratio = min(maxLength / eventBoundaryMapRect.width, maxLength / eventBoundaryMapRect.height)
        let outputImageSize = CGSize(width: eventBoundaryMapRect.width * ratio, height: eventBoundaryMapRect.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(outputImageSize, false, 0.0)
        
        // 2. 現在のグラフィックスコンテキストを取得
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return 0
        }
        
        var boundaryScaledTransform = CGAffineTransform(scaleX: ratio, y: ratio)
        let scaledEventBoundaryPath = eventBoundaryPath.copy(using: &boundaryScaledTransform)!
        context.setFillColor(UIColor.black.cgColor)
        context.addPath(scaledEventBoundaryPath)
        context.fillPath()
        
        // 4. UIImageを取得
        let boudaryImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 5. 画像コンテキストを終了
        UIGraphicsEndImageContext()
        
        UIGraphicsBeginImageContextWithOptions(outputImageSize, false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return 0
        }
        
        var routeScaledTransform = CGAffineTransform(scaleX: ratio, y: ratio)
        let scaledRoutePath = routePath.copy(using: &routeScaledTransform)!
        var routeMoveTransform = CGAffineTransform(translationX: (routeMapRect.origin.x - eventBoundaryMapRect.origin.x)*ratio, y: (routeMapRect.origin.y - eventBoundaryMapRect.origin.y)*ratio)
        let movedRoutePath = scaledRoutePath.copy(using: &routeMoveTransform)!
        
        let lineWidth: CGFloat = Game.lineLength * ratio
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)
        context.addPath(movedRoutePath)
        context.setStrokeColor(UIColor.black.cgColor)
        context.strokePath()
        
        context.setFillColor(UIColor.green.cgColor)
        for eventCircle in eventCircles {
            let eventMapRect = eventCircle.boundingMapRect
            var eventScaledTransform = CGAffineTransform(scaleX: ratio, y: ratio)
            var eventMovedTransform = CGAffineTransform(translationX: (eventMapRect.origin.x - eventBoundaryMapRect.origin.x)*ratio, y: (eventMapRect.origin.y - eventBoundaryMapRect.origin.y)*ratio)
            let eventCircleRenderer = MKCircleRenderer(circle: eventCircle)
            let scaledEventCirclePath = eventCircleRenderer.path.copy(using: &eventScaledTransform)!
            let movedEventCirclePath = scaledEventCirclePath.copy(using: &eventMovedTransform)!
            context.addPath(movedEventCirclePath)
            context.fillPath()
        }
        
        // 4. UIImageを取得
        let routeImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 5. 画像コンテキストを終了
        UIGraphicsEndImageContext()
        
        let boudaryImageAlphaRatio = boudaryImage!.calcAlphaRatio()
        let routeImageAlphaRatio = routeImage!.calcAlphaRatio()
        return Double(routeImageAlphaRatio / boudaryImageAlphaRatio)
    }
}

fileprivate extension UIImage {
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
