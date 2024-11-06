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
    let eventArea: Area = PiyoParkArea()
    //前の軌跡を消すために保持しておく
    var userTrajectoryLine: MKPolyline?
    
    private var locationService: LocationService = RealLocationService()
    private var cleanProgressCalculator: CleanProgressCalculator = .init()
    private var qrReader: QRReader = .init()
    
    private var qrScanningView: UIView?
    @ViewLoading var mapView: MKMapView
    @ViewLoading private var noticeLabel: NoticeLabel
    @ViewLoading private var progressBar: ProgressBar
    @ViewLoading private var gameCompleteView: UIView
    @ViewLoading private var reportButton: UIButton
    
    let userAnnotaionIdentifier = "user"
    let eventAnnotaionIdentifier = "eventAnnnotation"
    
    override func viewDidLoad() {
        
        locationService.delegate = self
        locationService.startUpdatingLocation()
        qrReader.delegate = self
        
//        Viewの設定
        setUpMapView()
        setUpQRReaderLauncherView()
        setUpProgressBar()
        setUpReportButton()
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
        gameCompleteView = UIView(frame: self.view.frame)
        gameCompleteView.isUserInteractionEnabled = false
        gameCompleteView.backgroundColor = .clear
        gameCompleteView.alpha = 0.0
        self.view.addSubview(gameCompleteView)
        
//        お湯の湯気感をグラデーションで表現
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.9).cgColor,
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.white.withAlphaComponent(0.8).cgColor,
            UIColor(hex: "#d6e9ca")!.cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.locations = [0.0, 0.5, 0.6, 0.7, 0.8]
        gameCompleteView.layer.addSublayer(gradientLayer)
        
        var configuration = UIButton.Configuration.filled()
        configuration.title = "お疲れ様でした"
        configuration.baseBackgroundColor = UIColor(hex: "#4B2D1C")
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .capsule
        configuration.buttonSize = .large
        let backButton = UIButton(configuration: configuration)
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOpacity = 1
        backButton.layer.shadowRadius = 3
        backButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        self.gameCompleteView.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            backButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100),
            backButton.widthAnchor.constraint(equalToConstant: 200),
        ])
    }
    
    @objc func didTapBackButton() {
        self.dismiss(animated: true)
    }
    
    private func setUpMapView() {
        mapView = MKMapView(frame: .zero)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.setRegion(.init(eventArea.boundingMapRect), animated: true)
//        mapView.setCameraBoundary(.init(mapRect: eventArea.boundingRect), animated: true)
////        200は適当に付けてるだけ
////        widthやheightをmaxCenterCoordinateDistanceに設定するとAreaもう一個分だけ移動できるようになる.
////        今回はそこまで移動できても意味がないので半分だけ余白を持たせている。
//        mapView.setCameraZoomRange(.init(minCenterCoordinateDistance: 200,maxCenterCoordinateDistance: min(eventArea.boundingMapRect.width, eventArea.boundingMapRect.height)*0.5), animated: true)
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
        
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: eventAnnotaionIdentifier)
        mapView.register(UserView.self, forAnnotationViewWithReuseIdentifier: userAnnotaionIdentifier)
        
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
        self.progressBar = ProgressBar(frame: .zero)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 80),
            progressBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            progressBar.widthAnchor.constraint(equalToConstant: 200),
            progressBar.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    private func setUpReportButton() {
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
        reportButton.layer.shadowColor = UIColor.black.cgColor
        reportButton.layer.shadowOpacity = 1
        reportButton.layer.shadowRadius = 3
        reportButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.view.addSubview(reportButton)
        
        NSLayoutConstraint.activate([
            reportButton.centerYAnchor.constraint(equalTo: progressBar.centerYAnchor),
            reportButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
        ])
    }
    
    @objc func didTapReportButton() {
        self.progressBar.progress = cleanProgressCalculator.calculate(targetArea: eventArea, userTrajectory: locationService.userTrajectory)
        Task { @MainActor in
            await UIView.animate(withDuration: 1.0, animations: {
                self.gameCompleteView.alpha = 1.0
    //            後ろへのタッチをブロックする
                self.gameCompleteView.isUserInteractionEnabled = true
                self.mapView.setVisibleMapRect(self.eventArea.boundingMapRect, animated: true)
            })
            try await self.noticeLabel.show(text: Game.completeMessage(areaName: self.eventArea.name, percentage: self.progressBar.progress * 100))
        }
    }
    
    @objc func startQRReader() {
        qrReader.start()
        qrScanningView = .init(frame: self.view.frame)
        //エミュレータでcloseボタンを視認できるよう
        qrScanningView?.backgroundColor = .black
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: qrReader.session)
        previewLayer.frame = qrScanningView!.bounds
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoRotationAngle = 90
        
        qrScanningView?.layer.addSublayer(previewLayer)
        self.view.addSubview(qrScanningView!)
        
        var cancelButtonconfig = UIButton.Configuration.plain()
        cancelButtonconfig.image = UIImage(systemName: "xmark")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        cancelButtonconfig.baseForegroundColor = .systemBlue
        let cancelButton = UIButton(configuration: cancelButtonconfig)
        cancelButton.addTarget(self, action: #selector(stopQRReader), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        self.qrScanningView?.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 5),
            cancelButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            cancelButton.widthAnchor.constraint(equalToConstant: 50),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    @objc func stopQRReader() {
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
            return mapView.dequeueReusableAnnotationView(withIdentifier: userAnnotaionIdentifier, for: annotation)
        } else if let badgeAnnotation = annotation as? PointAnnotation {
            let badgeAnnotaionView =  mapView.dequeueReusableAnnotationView(withIdentifier: eventAnnotaionIdentifier, for: annotation)
            badgeAnnotaionView.image = UIImage(named: badgeAnnotation.identifier)
            badgeAnnotaionView.bounds.size = CGSize(width: 60, height: 60)
            return badgeAnnotaionView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polygon = overlay as? MKPolygon {
            let polygonRenderer = MKPolygonRenderer(overlay: polygon)
            polygonRenderer.fillColor = UIColor(patternImage: UIImage(named: "black")!)
            return polygonRenderer
        }
        
        if let polyline = overlay as? MKPolyline {
            let polylineRenderer = ErasePolylineRenderer(polyline: polyline)
            return polylineRenderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
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


extension GameViewController {
    func debugImage() -> UIImage? {
        let maxLength: Double = 300
        
        let eventBoundary = eventArea.boundary
        let eventBoundaryPolygon = MKPolygon(coordinates: eventBoundary.map({ $0.coordinate }), count: eventBoundary.count)
        let eventBoundaryRenderer = MKPolygonRenderer(polygon: eventBoundaryPolygon)
        let eventBoundaryPath = eventBoundaryRenderer.path!
        let eventBoundaryMapRect = eventBoundaryPolygon.boundingMapRect
        
        let routePolyline = MKPolyline(coordinates: locationService.userTrajectory.map({ $0.coordinate }), count: locationService.userTrajectory.count)
        let routePolylineRenderer = ErasePolylineRenderer(polyline: routePolyline)
        guard let routePath = routePolylineRenderer.path else { return nil }
        let routeMapRect = routePolyline.boundingMapRect
        
        let ratio = min(maxLength / eventBoundaryMapRect.width, maxLength / eventBoundaryMapRect.height)
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
        
        let lineWidth: CGFloat = Game.lineLength * ratio
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)
        context.addPath(movedRoutePath)
        context.setBlendMode(.clear)
        context.setStrokeColor(UIColor.black.cgColor)
        context.strokePath()
        // 4. UIImageを取得
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        // 5. 画像コンテキストを終了
        UIGraphicsEndImageContext()
        
        return image
    }
}
