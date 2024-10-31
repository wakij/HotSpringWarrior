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
    @ViewLoading var locationManager: CLLocationManager
    
    let eventArea: Area = OtaArea()
    
    private var userTrajectory: [CLLocation] = []
    var userTrajectoryLine: MKPolyline?
    
    private var qrReader: QRReader = .init()
    var qrReaderView: UIView?
    
    override func viewDidLoad() {
        
        setUpLocationManager()
        
        mapView = MKMapView(frame: .zero)
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.setRegion(.init(eventArea.boundingRect), animated: true)
        mapView.setCameraBoundary(.init(mapRect: eventArea.boundingRect), animated: true)
//        200は適当に付けてるだけ
//        widthやheightをmaxCenterCoordinateDistanceに設定するとAreaもう一個分だけ移動できるようになる.
//        今回はそこまで移動できても意味がないので半分だけ余白を持たせている。
        mapView.setCameraZoomRange(.init(minCenterCoordinateDistance: 200,maxCenterCoordinateDistance: min(eventArea.boundingRect.width, eventArea.boundingRect.height)*0.5), animated: true)
        mapView.pointOfInterestFilter = MKPointOfInterestFilter(including: [])
        mapView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mapView)
        
//        QRコードリーダー
        qrReader.delegate = self
        
        let qrCodeReaderView = UIImageView(image: UIImage(systemName: "qrcode.viewfinder"))
        qrCodeReaderView.isUserInteractionEnabled = true
        qrCodeReaderView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(qrCodeReaderView)
        
        let qrCodeReaderViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(startQRRead))
        qrCodeReaderView.addGestureRecognizer(qrCodeReaderViewTapGestureRecognizer)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: self.view.topAnchor),
            mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            qrCodeReaderView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            qrCodeReaderView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20),
            qrCodeReaderView.widthAnchor.constraint(equalToConstant: 60),
            qrCodeReaderView.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        drawEventArea()
    }
    
    // フォアグラウンドに復帰した時に呼ばれるメソッド
    @objc func appWillEnterForeground() {
        updateUserPath()
    }
    
    private func setUpLocationManager() {
        locationManager = CLLocationManager()
        locationManager.distanceFilter = 10
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
    
    private func drawEventArea() {
        let boundary = eventArea.boundary
        let boundaryPolygon = MKPolygon(coordinates: boundary.map({ $0.coordinate }), count: boundary.count)
        mapView.addOverlay(boundaryPolygon)
    }
    
//    差分更新の方がいいのかなぁ
//    userLocationsを形状があまり変化しないように間引く処理とかも追加したい
    private func updateUserPath() {
        if userTrajectory.count < 2 { return }
        //        前の軌跡は消去する
        if let userTrajectoryLine {
            mapView.removeOverlay(userTrajectoryLine)
        }
        
        userTrajectoryLine = MKPolyline(coordinates: userTrajectory.map({ $0.coordinate }), count: userTrajectory.count)
        mapView.addOverlay(userTrajectoryLine!)
    }
    
    @objc func startQRRead() {
        qrReader.start()
        qrReaderView = .init(frame: self.view.frame)
        qrReaderView?.backgroundColor = .clear
        
        let layer = AVCaptureVideoPreviewLayer(session: qrReader.session)
        layer.frame = qrReaderView!.bounds
        layer.videoGravity = .resizeAspectFill
        layer.connection?.videoRotationAngle = .zero
        
        qrReaderView?.layer.addSublayer(layer)
        self.view.addSubview(qrReaderView!)
    }
    
    func stopQRRead() {
        qrReader.stop()
        
        DispatchQueue.main.async {
            self.qrReaderView?.removeFromSuperview()
            self.qrReaderView = nil
        }
    }
}

extension GameViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
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

extension GameViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
//            Alertを出して設定から変更してもらう必要がありそう
            break
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let loc = locations.last else { return }
//        userLocations.append(loc)
//        
////        UIの更新はフォアグラウンドにいる時に限定する
//        if UIApplication.shared.applicationState == .active {
//            updateUserPath()
//            let cr = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
//            mapView.setRegion(cr, animated: true)
//        }
    }
}

extension GameViewController: QRReaderDelegate {
    func didRead(_ text: String) {
        print(text)
        stopQRRead()
    }
}
