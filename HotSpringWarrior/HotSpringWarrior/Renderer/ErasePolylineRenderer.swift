//
//  ZoomingPolylineRenderer.swift
//  HotSpringWarrior
//
//  Created by tomoshigewakita on 2024/09/06.
//

import Foundation
import MapKit

class ErasePolylineRenderer :  MKPolylineRenderer {
    override public func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        context.setBlendMode(.clear)
        context.setLineWidth(Game.lineLength)
        context.setLineCap(.round)
        context.setStrokeColor(UIColor.black.cgColor)
        context.addPath(path)
        context.strokePath()
    }
}
