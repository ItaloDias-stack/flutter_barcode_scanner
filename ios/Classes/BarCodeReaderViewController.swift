import UIKit

class BarCodeReaderViewController: UIViewController {
    @IBOutlet var scannerView: BarCodeReaderView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var maskContainer: UIView!
    @IBOutlet var textLabel: UILabel!
    public var delegate: ScanBarcodeDelegate? = nil

    override var prefersStatusBarHidden: Bool { true }

    override func viewDidLoad() {
        super.viewDidLoad()
        scannerView.delegate = self
        backButton.transform = .init(rotationAngle: .pi/2.0)
        textLabel.transform = .init(rotationAngle: .pi/2.0)
        MaskOverlayView.newOverlay().addConstraintEmbed(into: maskContainer)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scannerView.startScanning()
    }
  
  @IBAction func backAction() {
    self.dismiss(animated: true)
  }
}

extension BarCodeReaderViewController: CodeScannerDelegate {
    func scanningDidStop() {}

    func scanningDidFail(permissions: Bool) {}

    func scanningSucceeded(with code: String) {
      print(code)
        delegate?.userDidScanWith(barcode: code)
      
      if(SwiftFlutterBarcodeScannerPlugin.isContinuousScan){
        SwiftFlutterBarcodeScannerPlugin.onBarcodeScanReceiver(barcode: code)
      }else{
        if presentedViewController != nil {
          return
        }
        if self.delegate != nil {
          self.dismiss(animated: true, completion: {
            self.delegate?.userDidScanWith(barcode: code)
          })
        }
      }
    }
}
