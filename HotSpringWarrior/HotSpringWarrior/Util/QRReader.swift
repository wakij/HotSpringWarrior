//
//  QRReader.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/10/31.
//
import Foundation
import AVFoundation

protocol QRReaderDelegate: NSObject {
    func didRead(_ text: String) //テキストを読み取った時
}

final class QRReader: NSObject {
    weak var delegate: QRReaderDelegate?
    
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    
    private var videoDeviceInput: AVCaptureDeviceInput!
    
    private let metadataOutput = AVCaptureMetadataOutput()
    private let metadataObjectQueue = DispatchQueue(label: "metadataObjectQueue")
    
    private func configureSession() {
        session.beginConfiguration()
        let defaultVideoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        guard let videoDevice = defaultVideoDevice else {
            session.commitConfiguration()
            return
        }
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            }
        } catch {
            session.commitConfiguration()
            return
        }
        
        if session.canAddOutput(metadataOutput){
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: metadataObjectQueue)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            session.commitConfiguration()
        }
        
        session.commitConfiguration()
    }
    
    func start() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            sessionQueue.async {
                self.configureSession()
                self.session.startRunning()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
//                    アラートを出す？
                }
            }
        default:
            break
        }
    }
    
    func stop() {
        self.metadataOutput.setMetadataObjectsDelegate(nil, queue: nil)
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
}

extension QRReader: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        guard let metadataObject = metadataObjects.first else { return }
        guard let machineReadableCode = metadataObject as? AVMetadataMachineReadableCodeObject, machineReadableCode.type == .qr, let stringValue = machineReadableCode.stringValue else { return }
        
        delegate?.didRead(stringValue)
    }
}
