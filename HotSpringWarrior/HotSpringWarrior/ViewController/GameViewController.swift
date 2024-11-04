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
    let eventArea: Area = OtaArea()
    //前の軌跡を消すために保持しておく
    var userTrajectoryLine: MKPolyline?
    private var locationService: LocationService = RealLocationService()
    private var qrReader: QRReader = .init()
    private var qrScanningView: UIView?
    
    @ViewLoading var mapView: MKMapView
    @ViewLoading private var noticeLabel: NoticeLabel
    @ViewLoading private var progressBar: ProgressBar
    @ViewLoading private var gameCompleteBgView: UIView
    @ViewLoading private var reportButton: UIButton
    
    override func viewDidLoad() {
        
        locationService.startUpdatingLocation()
        locationService.delegate = self
//        QRコードリーダー
        qrReader.delegate = self
        
//        Viewの設定
        setUpMapView()
        setUpQRReaderLauncherView()
        setUpProgressBar()
        setUpButton()
        setUpGameCompleteBgView()
        setUpNoticeLabel()
        
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
    
    private func updateUserPath() {
        if locationService.userTrajectory.count < 2 { return }
        //        前の軌跡は消去する
        if let userTrajectoryLine {
            mapView.removeOverlay(userTrajectoryLine)
        }
        
        userTrajectoryLine = MKPolyline(coordinates: locationService.userTrajectory.map({ $0.coordinate }), count: locationService.userTrajectory.count)
        mapView.addOverlay(userTrajectoryLine!)
    }
    
    private func setUpGameCompleteBgView() {
        gameCompleteBgView = UIView(frame: self.view.frame)
        gameCompleteBgView.isUserInteractionEnabled = false
        gameCompleteBgView.backgroundColor = .clear
        gameCompleteBgView.alpha = 0.0
        self.view.addSubview(gameCompleteBgView)
        
//        お湯の湯気感をグラデーションで表現
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds

        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.1).cgColor,
            UIColor.white.withAlphaComponent(1.0).cgColor,
            UIColor.white.withAlphaComponent(0.8).cgColor,
            UIColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 1.0).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.locations = [0.0, 0.5, 0.7, 1.0]
        gameCompleteBgView.layer.addSublayer(gradientLayer)
    }
    
    private func setUpMapView() {
        mapView = MKMapView(frame: .zero)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsCompass = false
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
        
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "eventAnnnotation")
        mapView.register(UserView.self, forAnnotationViewWithReuseIdentifier: "user")
        
//        イベントスポットの登録
        eventArea.eventSpots.forEach({
            mapView.addAnnotation($0)
        })
        
        drawEventArea()
    }
    
    private func setUpNoticeLabel() {
        self.noticeLabel = NoticeLabel(frame: .zero)
        noticeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(noticeLabel)
        
        NSLayoutConstraint.activate([
            noticeLabel.centerXAnchor.constraint(equalTo: self.mapView.centerXAnchor),
            noticeLabel.centerYAnchor.constraint(equalTo: self.mapView.centerYAnchor),
            noticeLabel.widthAnchor.constraint(equalTo: self.mapView.widthAnchor, multiplier: 0.8)
        ])
    }
    
    private func setUpQRReaderLauncherView() {
        let qrCodeImageView = UIImageView(image: UIImage(systemName: "qrcode.viewfinder"))
        qrCodeImageView.tintColor = UIColor(hex: "#F37167")
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
    
    private func setUpProgressBar() {
        self.progressBar =  ProgressBar(frame: .zero)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 80),
            progressBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            progressBar.widthAnchor.constraint(equalToConstant: 200),
            progressBar.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    private func setUpButton() {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "報告"
        configuration.baseBackgroundColor = .white
        configuration.baseForegroundColor = .black
        configuration.cornerStyle = .capsule
        configuration.image = UIImage(named: "hotSpring")?.withTintColor(.red)
        configuration.imagePadding = 10
        configuration.imagePlacement = .leading
        self.reportButton = UIButton(configuration: configuration)
        reportButton.addTarget(self, action: #selector(didTapReportButton), for: .touchUpInside)
        reportButton.translatesAutoresizingMaskIntoConstraints = false
        reportButton.imageView?.contentMode = .scaleAspectFit
        self.view.addSubview(reportButton)
        
        NSLayoutConstraint.activate([
            reportButton.centerYAnchor.constraint(equalTo: progressBar.centerYAnchor),
            reportButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
        ])
    }
    
    @objc func didTapReportButton() {
        Task { @MainActor in
            await UIView.animate(withDuration: 1.0, animations: {
                self.gameCompleteBgView.alpha = 0.8
    //            後ろへのタッチをブロックする
                self.gameCompleteBgView.isUserInteractionEnabled = true
                self.mapView.setVisibleMapRect(self.eventArea.boundingRect, animated: true)
            })
            try await self.noticeLabel.show(text: Game.completeMessage(areaName: self.eventArea.name, percentage: self.progressBar.progress))
            try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
            self.dismiss(animated: true)
        }
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
    
    func calcRatio() -> Float {
        let maxSize: Double = 300
        
        let eventBoundary = eventArea.boundary
        let eventBoundaryPolygon = MKPolygon(coordinates: eventBoundary.map({ $0.coordinate }), count: eventBoundary.count)
        let eventBoundaryRenderer = MKPolygonRenderer(polygon: eventBoundaryPolygon)
        let eventBoundaryPath = eventBoundaryRenderer.path!
        let eventBoundaryMapRect = eventBoundaryPolygon.boundingMapRect
        
        let routePolyline = MKPolyline(coordinates: locationService.userTrajectory.map({ $0.coordinate }), count: locationService.userTrajectory.count)
        let routePolylineRenderer = ErasePolylineRenderer(polyline: routePolyline)
        let routePath = routePolylineRenderer.path!
        let routeMapRect = routePolyline.boundingMapRect
        
        let ratio = min(maxSize / eventBoundaryMapRect.width, maxSize / eventBoundaryMapRect.height)
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
        
        let lineWidth: CGFloat = 150 * ratio
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)
        context.addPath(movedRoutePath)
        context.setStrokeColor(UIColor.black.cgColor)
        context.strokePath()
        // 4. UIImageを取得
        let routeImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 5. 画像コンテキストを終了
        UIGraphicsEndImageContext()
        
        let boudaryImageAlphaRatio = boudaryImage!.calcAlphaRatio()
        let routeImageAlphaRatio = routeImage!.calcAlphaRatio()
        return routeImageAlphaRatio / boudaryImageAlphaRatio
    }
    
    func debugImage() -> UIImage? {
        let maxSize: Double = 300
        
        let eventBoundary = eventArea.boundary
        let eventBoundaryPolygon = MKPolygon(coordinates: eventBoundary.map({ $0.coordinate }), count: eventBoundary.count)
        let eventBoundaryRenderer = MKPolygonRenderer(polygon: eventBoundaryPolygon)
        let eventBoundaryPath = eventBoundaryRenderer.path!
        let eventBoundaryMapRect = eventBoundaryPolygon.boundingMapRect
        
        let routePolyline = MKPolyline(coordinates: locationService.userTrajectory.map({ $0.coordinate }), count: locationService.userTrajectory.count)
        let routePolylineRenderer = ErasePolylineRenderer(polyline: routePolyline)
        let routePath = routePolylineRenderer.path!
        let routeMapRect = routePolyline.boundingMapRect
        
        let ratio = min(maxSize / eventBoundaryMapRect.width, maxSize / eventBoundaryMapRect.height)
        let outputImageSize = CGSize(width: eventBoundaryMapRect.width * ratio, height: eventBoundaryMapRect.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(outputImageSize, false, 0.0)
        
        // 2. 現在のグラフィックスコンテキストを取得
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        var boundaryScaledTransform = CGAffineTransform(scaleX: ratio, y: ratio)
        let scaledEventBoundaryPath = eventBoundaryPath.copy(using: &boundaryScaledTransform)!
        context.setFillColor(UIColor.black.cgColor)
        context.addPath(scaledEventBoundaryPath)
        context.fillPath()
        
        var routeScaledTransform = CGAffineTransform(scaleX: ratio, y: ratio)
        let scaledRoutePath = routePath.copy(using: &routeScaledTransform)!
        var routeMoveTransform = CGAffineTransform(translationX: (routeMapRect.origin.x - eventBoundaryMapRect.origin.x)*ratio, y: (routeMapRect.origin.y - eventBoundaryMapRect.origin.y)*ratio)
        let movedRoutePath = scaledRoutePath.copy(using: &routeMoveTransform)!
        
        let lineWidth: CGFloat = 150 * ratio
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)
        context.addPath(movedRoutePath)
        context.setStrokeColor(UIColor.red.cgColor)
        context.strokePath()
        // 4. UIImageを取得
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        // 5. 画像コンテキストを終了
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension GameViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return mapView.dequeueReusableAnnotationView(withIdentifier: "user", for: annotation)
        } else if let badgeAnnotation = annotation as? PointAnnotation {
            let badgeAnnotaionView =  mapView.dequeueReusableAnnotationView(withIdentifier: "eventAnnnotation", for: annotation)
            badgeAnnotaionView.image = UIImage(named: badgeAnnotation.identifier)
            badgeAnnotaionView.bounds.size = CGSize(width: 60, height: 60)
            return badgeAnnotaionView
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
        stopQRReader()
        
//       実際はゲームの状態によって分岐する
//        今は例としてお湯を手に入れたとする
        DispatchQueue.main.async {
            guard let userView = self.mapView.view(for: self.mapView.userLocation), let userView = userView as? UserView else { return }
            userView.holdHotWater {
                self.noticeLabel.show(text: Game.getHotWater, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        self.noticeLabel.isHidden = true
                    })
                })
                userView.startWalkingAnimation()
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
