//
//  GameViewController.swift
//  HotSpringWarrior
//
//  Created by tomoshigewakita on 2024/09/06.
//

import Foundation
import UIKit
import MapKit

class GameViewController: UIViewController {
    @ViewLoading var mapView: MKMapView
    @ViewLoading var locationManager: CLLocationManager
    
    private var userLocations: [CLLocation] = Boundary.sampleUserTrajectory
    
    lazy var otaRegion: MKPolygon = {
        let otaLocData = Boundary.otaRegion
        let otaRegion = MKPolygon(coordinates: otaLocData.map({ $0.coordinate }), count: otaLocData.count)
        return otaRegion
    }()
    
    var userTrajectory: MKPolyline?
    
    override func viewDidLoad() {
        
        setUpLocationManager()
        
        mapView = MKMapView(frame: .zero)
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: self.view.topAnchor),
            mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        drawOtaBoundary()
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
    
    private func drawOtaBoundary() {
        mapView.addOverlay(otaRegion)
    }
    
//    差分更新の方がいいのかなぁ
//    userLocationsを形状があまり変化しないように間引く処理とかも追加したい
    private func updateUserPath() {
        if userLocations.count < 2 { return }
        //        前の軌跡は消去する
        if let userTrajectory {
            mapView.removeOverlay(userTrajectory)
        }
        
        userTrajectory = MKPolyline(coordinates: userLocations.map({ $0.coordinate }), count: userLocations.count)
        mapView.addOverlay(userTrajectory!)
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
