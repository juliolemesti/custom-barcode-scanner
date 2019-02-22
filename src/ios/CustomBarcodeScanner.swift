import AVFoundation

@objc(CustomBarcodeScanner)
class CustomBarcodeScanner : CDVPlugin, AVCaptureMetadataOutputObjectsDelegate, URLSessionDelegate {

    var callbackId: String?
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var isBinaryContent: Bool?
    var cancelButton: UIButton?

    var currentCamera: Int = 0;
    var frontCamera: AVCaptureDevice?
    var backCamera: AVCaptureDevice?

    @objc(scanQRCode:)
    func scanQRCode(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId;
        self.doScan();
    }

    @objc(scanBarcode:)
    func scanBarcode(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId;
        self.doScan(readQRcode: false);
    }

    func doScan(readQRcode: Bool? = true){
        let view: UIView = self.webView.superview!

        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if (status == AVAuthorizationStatus.restricted) {
            self.sendResultFailure(error: nil)
            return
        } else if status == AVAuthorizationStatus.denied {
            self.sendResultFailure(error: nil)
            return
        }

        let availableVideoDevices = AVCaptureDevice.devices(for: AVMediaType.video)
        for device in availableVideoDevices {
            if (device as AnyObject).position == AVCaptureDevice.Position.back {
                backCamera = device
            }
            else if (device as AnyObject).position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        // older iPods have no back camera
        if(backCamera == nil){
            currentCamera = 1
        }

        do {

            captureSession = AVCaptureSession()

            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input: AVCaptureDeviceInput
            input = try self.createCaptureDeviceInput()

            // Set the input device on the capture session.
            self.captureSession!.addInput(input)

            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession!.addOutput(captureMetadataOutput)

            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            let captureObjectType = readQRcode! ? AVMetadataObject.ObjectType.qr : AVMetadataObject.ObjectType.interleaved2of5
            captureMetadataOutput.metadataObjectTypes = [captureObjectType]

            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer!.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)

            // Start video capture.
            captureSession!.startRunning()

            cancelButton = UIButton(frame: CGRect(x: 16, y: 30, width: 80, height: 30))
            cancelButton?.layer.borderWidth = 1
            cancelButton?.layer.borderColor = UIColor.white.cgColor
            cancelButton?.layer.cornerRadius = CGFloat(14)
            cancelButton?.setTitle("Voltar", for: .normal)
            cancelButton?.titleLabel?.font = UIFont(name: "Apple SD Gothic Neo", size: 14);
            cancelButton?.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
            view.addSubview(cancelButton!)

            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }


        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            self.sendResultFailure(error: error)
            return
        }
    }

    func createCaptureDeviceInput() throws -> AVCaptureDeviceInput {
        var captureDevice: AVCaptureDevice
        if(currentCamera == 0){
            if(backCamera != nil){
                captureDevice = backCamera!
            } else {
                throw CaptureError.backCameraUnavailable
            }
        } else {
            if(frontCamera != nil){
                captureDevice = frontCamera!
            } else {
                throw CaptureError.frontCameraUnavailable
            }
        }
        let captureDeviceInput: AVCaptureDeviceInput
        do {
            captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error as NSError {
            throw CaptureError.couldNotCaptureInput(error: error)
        }
        return captureDeviceInput
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }

        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == AVMetadataObject.ObjectType.qr || metadataObj.type == AVMetadataObject.ObjectType.interleaved2of5 {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds

            sendResultSuccess(msg: metadataObj.stringValue ?? "")
            self.stopCapture();

            return;
        }

        self.sendResultFailure(error: nil);
    }

    @objc(cancelButtonAction:)
      func cancelButtonAction(sender: UIButton!) {
        self.stopCapture()

        self.sendResultSuccess(msg: "")
    }

    func stopCapture(){
        if(captureSession != nil) {captureSession!.stopRunning()}
        if(videoPreviewLayer != nil) {videoPreviewLayer!.removeFromSuperlayer()}
        if(cancelButton != nil) {cancelButton!.removeFromSuperview()}

        captureSession = nil
        videoPreviewLayer = nil
        cancelButton = nil
    }

    func sendResultFailure(error: Error? = nil, msg: String = ""){
        var message: String
        if (error != nil){
            message = error.debugDescription
        } else {
            message = msg
        }

        let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: message
        )

        sendResult(result: pluginResult!)
    }

    func sendResultSuccess(msg: String?){
        let message = msg ?? "Sucesso";
        let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: message
        )

        sendResult(result: pluginResult!)
    }

    func sendResultObject(data: Dictionary<String, Any>){
        let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: data
        )

        sendResult(result: pluginResult!)
    }

    func sendResult(result: CDVPluginResult){
        self.commandDelegate!.send(result, callbackId: self.callbackId!)
        dismiss()
    }

    func dismiss(){
        captureSession?.stopRunning()

        videoPreviewLayer?.removeFromSuperlayer()
        videoPreviewLayer = nil

        qrCodeFrameView?.removeFromSuperview()
        qrCodeFrameView = nil

        captureSession = nil
        currentCamera = 0
        frontCamera = nil
        backCamera = nil
    }

    enum CaptureError: Error {
        case backCameraUnavailable
        case frontCameraUnavailable
        case couldNotCaptureInput(error: NSError)
    }

}
