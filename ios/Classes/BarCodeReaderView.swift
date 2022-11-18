import Foundation
import AVFoundation

class BarCodeReaderView: QRCodeScannerView {
    override var metadataOutputTypes: [AVMetadataObject.ObjectType] { [.interleaved2of5] }
}
