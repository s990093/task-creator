import SwiftUI
import AVFoundation
import Vision

struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var faceEstimator: FaceEstimator
    @Binding var isMonitoring: Bool
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.faceEstimator = faceEstimator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        if isMonitoring {
            uiViewController.startSession()
        } else {
            uiViewController.stopSession()
        }
    }
}

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var faceEstimator: FaceEstimator?
    private let captureSession = AVCaptureSession()
    private var lastProcessingTime: TimeInterval = 0
    private let processingInterval: TimeInterval = 1.0
    private var isSessionConfigured = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Don't start immediately, wait for updateUIViewController
    }
    
    func startSession() {
        if !isSessionConfigured {
            setupCamera()
            isSessionConfigured = true
        }
        
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    private func setupCamera() {
        captureSession.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        if captureSession.canAddInput(input) { captureSession.addInput(input) }
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(output) { captureSession.addOutput(output) }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        if timestamp - lastProcessingTime < processingInterval { return }
        lastProcessingTime = timestamp
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectFaceLandmarksRequest { [weak self] request, _ in
            guard let self = self else { return }
            
            if let results = request.results as? [VNFaceObservation], let observation = results.first {
                self.faceEstimator?.processObservation(observation)
            } else {
                self.faceEstimator?.updateNoFace()
            }
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored, options: [:]).perform([request])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.sublayers?.first?.frame = view.bounds
    }
}
