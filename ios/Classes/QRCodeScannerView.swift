import UIKit
import AVFoundation

protocol CodeScannerDelegate: NSObjectProtocol {
    func scanningDidStop()
    func scanningDidFail(permissions: Bool)
    func scanningSucceeded(with code: String)
}

class QRCodeScannerView: UIView {
    weak var delegate: CodeScannerDelegate?
    var metadataOutputTypes: [AVMetadataObject.ObjectType] { [.qr] }

    var captureSession: AVCaptureSession? {
        get {
            return layer.session
        }
        set {
            layer.session = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setup()
    }

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    override var layer: AVCaptureVideoPreviewLayer {
        /// avoiding SwiftLint force_cast warning
        guard let captureVideoPreviewLayer = super.layer as? AVCaptureVideoPreviewLayer else {
            return AVCaptureVideoPreviewLayer()
        }
        return captureVideoPreviewLayer
    }
}

extension QRCodeScannerView {
    var isRunning: Bool {
        return captureSession?.isRunning ?? false
    }

    func startScanning() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
            delegate?.scanningDidFail(permissions: true)
        } else {
            captureSession?.startRunning()
        }
    }

    func stopScanning() {
        captureSession?.stopRunning()
        delegate?.scanningDidStop()
    }

    /// Does the initial setup for captureSession
    private func setup() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch let error {
            print(error)
            return
        }

        if captureSession?.canAddInput(videoInput) ?? false {
            captureSession?.addInput(videoInput)
        } else {
            scanningDidFail()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession?.canAddOutput(metadataOutput) ?? false {
            captureSession?.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = metadataOutputTypes
        } else {
            scanningDidFail()
            return
        }

        self.layer.session = captureSession
        self.layer.videoGravity = .resizeAspectFill
        layer.zPosition = -1
        captureSession?.startRunning()
    }

    func scanningDidFail() {
        delegate?.scanningDidFail(permissions: false)
        captureSession = nil
    }

    func found(code: String) {
        delegate?.scanningSucceeded(with: code)
    }

}

extension QRCodeScannerView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        stopScanning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }

}
