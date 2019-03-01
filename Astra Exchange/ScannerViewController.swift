import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
	var captureSession = AVCaptureSession()
	var videoPreviewLayer: AVCaptureVideoPreviewLayer?
	var qrCodeFrameView: UIView?
	let supportedCodeTypes = [AVMetadataObject.ObjectType.upce, AVMetadataObject.ObjectType.code39, AVMetadataObject.ObjectType.code39Mod43, AVMetadataObject.ObjectType.code93, AVMetadataObject.ObjectType.code128, AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.aztec, AVMetadataObject.ObjectType.pdf417, AVMetadataObject.ObjectType.itf14, AVMetadataObject.ObjectType.dataMatrix, AVMetadataObject.ObjectType.interleaved2of5, AVMetadataObject.ObjectType.qr]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
		guard let captureDevice = deviceDiscoverySession.devices.first else { return }
		do {
			let input = try AVCaptureDeviceInput(device: captureDevice)
			captureSession.addInput(input)
			let captureMetadataOutput = AVCaptureMetadataOutput()
			captureSession.addOutput(captureMetadataOutput)
			captureMetadataOutput.setMetadataObjectsDelegate(self, queue: .main)
			captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
		} catch {
			navigationController?.popViewController(animated: true)
		}
		videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
		videoPreviewLayer?.frame = view.layer.bounds
		view.layer.addSublayer(videoPreviewLayer!)
		captureSession.startRunning()
		qrCodeFrameView = UIView()
		if let qrCodeFrameView = qrCodeFrameView {
			qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
			qrCodeFrameView.layer.borderWidth = 2
			view.addSubview(qrCodeFrameView)
			view.bringSubviewToFront(qrCodeFrameView)
		}
	}
	
	func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
		if metadataObjects.count == 0 {
			qrCodeFrameView?.frame = .zero
		} else {
			let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
			if supportedCodeTypes.contains(metadataObj.type) {
				let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
				qrCodeFrameView?.frame = barCodeObject!.bounds
				if let stringValue = metadataObj.stringValue {
					if let userIndex = User.id(stringValue) {
						vibrate()
						quickPayUser = users[userIndex]
						navigationController?.popViewController(animated: true)
					} else {
						showAlert("Invalid user")
					}
				}
			}
		}
	}
}
