//
//  GameViewController.swift
//  HotSpringWarrior
//
//  Created by tomoshigewakita on 2024/09/06.
//

import Foundation
import UIKit
import MapKit
import AVFoundation

class GameViewController: UIViewController {
    @ViewLoading var mapView: MKMapView
    
    let eventArea: Area = OtaArea()
    
    var userTrajectoryLine: MKPolyline?
    
    private var locationService: LocationService = RealLocationService()
    
    private var qrReader: QRReader = .init()
    private var qrScanningView: UIView?
    
    override func viewDidLoad() {
        
        locationService.startUpdatingLocation()
        locationService.delegate = self
//        QRコードリーダー
        qrReader.delegate = self
        
//        Viewの設定
        setUpMapView()
        setUpQRReaderLauncherView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    // フォアグラウンドに復帰した時に呼ばれるメソッド
    @objc func appWillEnterForeground() {
        updateUserPath()
    }
    
    private func drawEventArea() {
        let boundary = eventArea.boundary
        let boundaryPolygon = MKPolygon(coordinates: boundary.map({ $0.coordinate }), count: boundary.count)
        mapView.addOverlay(boundaryPolygon)
    }
    
//    差分更新の方がいいのかなぁ
//    userLocationsを形状があまり変化しないように間引く処理とかも追加したい
    private func updateUserPath() {
        if locationService.userTrajectory.count < 2 { return }
        //        前の軌跡は消去する
        if let userTrajectoryLine {
            mapView.removeOverlay(userTrajectoryLine)
        }
        
        userTrajectoryLine = MKPolyline(coordinates: locationService.userTrajectory.map({ $0.coordinate }), count: locationService.userTrajectory.count)
        mapView.addOverlay(userTrajectoryLine!)
    }
    
    private func setUpMapView() {
        mapView = MKMapView(frame: .zero)
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.setRegion(.init(eventArea.boundingRect), animated: true)
//        mapView.setCameraBoundary(.init(mapRect: eventArea.boundingRect), animated: true)
////        200は適当に付けてるだけ
////        widthやheightをmaxCenterCoordinateDistanceに設定するとAreaもう一個分だけ移動できるようになる.
////        今回はそこまで移動できても意味がないので半分だけ余白を持たせている。
        mapView.setCameraZoomRange(.init(minCenterCoordinateDistance: 200,maxCenterCoordinateDistance: min(eventArea.boundingRect.width, eventArea.boundingRect.height)*0.5), animated: true)
        mapView.pointOfInterestFilter = MKPointOfInterestFilter(including: [])
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        self.view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: self.view.topAnchor),
            mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        ])
        
        drawEventArea()
    }
    
    private func setUpQRReaderLauncherView() {
        let qrCodeImageView = UIImageView(image: UIImage(systemName: "qrcode.viewfinder"))
        qrCodeImageView.isUserInteractionEnabled = true
        qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(qrCodeImageView)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(startQRReader))
        qrCodeImageView.addGestureRecognizer(tapGestureRecognizer)
        
        NSLayoutConstraint.activate([
            qrCodeImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            qrCodeImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20),
            qrCodeImageView.widthAnchor.constraint(equalToConstant: 60),
            qrCodeImageView.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc func startQRReader() {
        qrReader.start()
        qrScanningView = .init(frame: self.view.frame)
        qrScanningView?.backgroundColor = .clear
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: qrReader.session)
        previewLayer.frame = qrScanningView!.bounds
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoRotationAngle = .zero
        
        qrScanningView?.layer.addSublayer(previewLayer)
        self.view.addSubview(qrScanningView!)
    }
    
    func stopQRReader() {
        qrReader.stop()
        
        DispatchQueue.main.async {
            self.qrScanningView?.removeFromSuperview()
            self.qrScanningView = nil
        }
    }
}

extension GameViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return UserView(annotation: annotation, reuseIdentifier: "User")
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polygon = overlay as? MKPolygon {
            let polygonRenderer = MKPolygonRenderer(overlay: polygon)
            polygonRenderer.fillColor = UIColor.black
            return polygonRenderer
        }
        
        if let polyline = overlay as? MKPolyline {
            let polylineRenderer = ErasePolylineRenderer(polyline: polyline)
            return polylineRenderer
        }
        
        fatalError()
    }
}

extension GameViewController: QRReaderDelegate {
    func didRead(_ text: String) {
        print(text)
        stopQRReader()
        
//       実際はゲームの状態によって分岐する
//        今は例としてお湯を手に入れたとする
        DispatchQueue.main.async {
            guard let userView = self.mapView.view(for: self.mapView.userLocation), let userView = userView as? UserView else { return }
            userView.holdHotWater {
                print("お湯を手に入れた！！！")
            }
        }
    }
}

extension GameViewController: LocationServiceDelegate {
    func locationService(_ service: any LocationService, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        updateUserPath()
        let cr = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
        mapView.setRegion(cr, animated: true)
    }
    
    func locationService(_ service: any LocationService, didFailWithError error: any Error) {
        return
    }
}
