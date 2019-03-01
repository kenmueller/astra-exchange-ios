import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
	var captureSession: AVCaptureSession!
	var previewLayer: AVCaptureVideoPreviewLayer!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		captureSession = AVCaptureSession()
		guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
		let videoInput: AVCaptureDeviceInput
		do { videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice) } catch { return }
		let metadataOutput = AVCaptureMetadataOutput()
		if captureSession.canAddInput(videoInput) && captureSession.canAddOutput(metadataOutput) {
			captureSession.addInput(videoInput)
			captureSession.addOutput(metadataOutput)
			metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
			metadataOutput.metadataObjectTypes = [.qr]
			previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
			previewLayer.frame = view.layer.bounds
			previewLayer.videoGravity = .resizeAspectFill
			view.layer.addSublayer(previewLayer)
			captureSession.startRunning()
		} else {
			failed()
		}
	}
	
	func failed() {
		let alertController = UIAlertController(title: "Scanning not supported", message: "", preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .default) { action in
			self.navigationController?.popViewController(animated: true)
		})
		present(alertController, animated: true)
		captureSession = nil
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if !(captureSession?.isRunning ?? false) {
			captureSession.startRunning()
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if captureSession?.isRunning ?? false {
			captureSession.stopRunning()
		}
	}
	
	func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
		captureSession.stopRunning()
		if let metadataObject = metadataObjects.first {
			guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject, let stringValue = readableObject.stringValue else { return }
			vibrate()
			if let quickPayVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "quickPay") as? QuickPayViewController, let userIndex = User.id(stringValue) {
				quickPayVC.user = users[userIndex]
				addChild(quickPayVC)
				quickPayVC.view.frame = view.frame
				view.addSubview(quickPayVC.view)
				quickPayVC.didMove(toParent: self)
			} else {
				showAlert("Invalid user")
			}
		}
		dismiss(animated: true)
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .portrait
	}
}
