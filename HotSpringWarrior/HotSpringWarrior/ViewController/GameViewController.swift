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
    
    private lazy var qrReader: QRReader = .init()
    private var qrScanningView: UIView?
    
    private var userView: UserView!
    
    override func viewDidLoad() {
        
        setUpLocationManager()
//        QRコードリーダー
        qrReader.delegate = self
        
//        Viewの設定
        setUpMapView()
        setUpQRReaderLauncherView()
        setUpUserView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
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
    
    private func setUpMapView() {
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
    
    private func setUpUserView() {
        userView = .init(center: self.view.center)
        self.mapView.addSubview(userView)
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
        stopQRReader()
        
//       実際はゲームの状態によって分岐する
//        今は例としてお湯を手に入れたとする
        DispatchQueue.main.async {
            self.userView.holdHotWater {
                print("お湯を手に入れた！")
            }
        }
    }
}
