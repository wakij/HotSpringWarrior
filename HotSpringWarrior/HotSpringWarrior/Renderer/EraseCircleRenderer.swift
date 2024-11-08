//
//  MKCircleRenderer.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/11/06.
//
import MapKit

final class EraseCircleRenderer: MKCircleRenderer {
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        context.setBlendMode(.clear)
        super.draw(mapRect, zoomScale: zoomScale, in: context)
    }
}
