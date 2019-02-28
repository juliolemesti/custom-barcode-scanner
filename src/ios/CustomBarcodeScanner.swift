import AVFoundation

@objc(CustomBarcodeScanner)
class CustomBarcodeScanner : CDVPlugin, AVCaptureMetadataOutputObjectsDelegate, URLSessionDelegate {

    var callbackId: String?
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var isBinaryContent: Bool?
    var cancelButton: UIButton?
    var flashButton: UIButton?
    var switchCameraButton: UIButton?

    var currentCamera: Int = 0;
    var frontCamera: AVCaptureDevice?
    var backCamera: AVCaptureDevice?

    var options: NSDictionary?
    var usingFrontCamera: Bool = false;

    var flashImage: UIImage?
    var flashOffImage: UIImage?

    var previewLayer: AVCaptureVideoPreviewLayer!

    @objc(scan:)
    func scanBarcode(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId;
        self.doScan(options: command.argument(at: 0) as! NSDictionary);
    }

    func doScan(options: NSDictionary){
        self.options = options
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
            let formats: NSArray = options.object(forKey: "formats") as! NSArray
            let format: NSString = formats.object(at: 0) as! NSString
            let captureObjectType = format == "QR_CODE" ? AVMetadataObject.ObjectType.qr : AVMetadataObject.ObjectType.interleaved2of5
            captureMetadataOutput.metadataObjectTypes = [captureObjectType]

            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer!.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)

            // Start video capture.
            captureSession!.startRunning()

            cancelButton = UIButton(frame: CGRect(x: 16, y: 45, width: 80, height: 30))
            cancelButton?.layer.borderWidth = 1
            cancelButton?.layer.borderColor = UIColor.white.cgColor
            cancelButton?.layer.cornerRadius = CGFloat(14)
            cancelButton?.setTitle("Voltar", for: .normal)
            cancelButton?.titleLabel?.font = UIFont(name: "Apple SD Gothic Neo", size: 14);
            cancelButton?.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
            view.addSubview(cancelButton!)

            let bundleUrl = Bundle.main.url(forResource: "CustomBarcodeScanner", withExtension: "bundle")
            let bundle = Bundle.init(url: bundleUrl!)

            let flashImagePath = bundle?.path(forResource: "lightbulb_on", ofType: "png")
            flashImage = UIImage.init(contentsOfFile: flashImagePath!)

            let flashOffImagePath = bundle?.path(forResource: "lightbulb_off", ofType: "png")
            flashOffImage = UIImage.init(contentsOfFile: flashOffImagePath!)

            flashButton = UIButton(frame: CGRect(x: 16, y: view.frame.size.height - 60, width: 50, height: 50))
            flashButton?.setImage(flashOffImage, for: .normal)
            flashButton?.addTarget(self, action: #selector(flashButtonAction), for: .touchUpInside)
            view.addSubview(flashButton!)

            switchCameraButton = UIButton(frame: CGRect(x: view.frame.size.width - 66, y: view.frame.size.height - 60, width: 50, height: 50))
            let switchImagePath = bundle?.path(forResource: "switch_camera", ofType: "png")
            let switchImage = UIImage.init(contentsOfFile: switchImagePath!)
            switchCameraButton?.setImage(switchImage, for: .normal)
            switchCameraButton?.addTarget(self, action: #selector(switchCameraButtonAction), for: .touchUpInside)
            view.addSubview(switchCameraButton!)

            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            qrCodeFrameView?.layer.borderColor = UIColor.red.cgColor
            qrCodeFrameView?.layer.borderWidth = 2
            qrCodeFrameView?.frame = CGRect(x: 30, y: 90, width: view.frame.size.width - 60, height: view.frame.size.height - 160)
            view.addSubview(qrCodeFrameView!)
            view.bringSubviewToFront(qrCodeFrameView!)

            let torchOn:Bool = options.object(forKey: "torchOn") as! Bool
            if (torchOn) {
                self.turnFlashOn()
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

    func getFrontCamera() -> AVCaptureDevice?{
        let videoDevices = AVCaptureDevice.devices(for: AVMediaType.video)

        for device in videoDevices{
            if device.position == AVCaptureDevice.Position.front {
                return device
            }
        }
        return nil
    }

    func getBackCamera() -> AVCaptureDevice?{
        let videoDevices = AVCaptureDevice.devices(for: AVMediaType.video)

        for device in videoDevices{
            if device.position == AVCaptureDevice.Position.back {
                return device
            }
        }
        return nil
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

    @objc(flashButtonAction:)
    func flashButtonAction(sender: UIButton!) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }

        do {
            try device.lockForConfiguration()

            if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                device.torchMode = AVCaptureDevice.TorchMode.off
                flashButton?.setImage(flashOffImage, for: .normal)
            } else {
                self.turnFlashOn()
            }

            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }

    @objc(switchCameraButtonAction:)
    func switchCameraButtonAction(sender: UIButton!) {
        usingFrontCamera = !usingFrontCamera
        do{
            captureSession!.removeInput(captureSession!.inputs.first!)

            if(usingFrontCamera){
                let captureDevice = getFrontCamera()
                let captureDeviceInput1 = try AVCaptureDeviceInput(device: captureDevice!)
                captureSession!.addInput(captureDeviceInput1)
            }else{
                let captureDevice = getBackCamera()
                let captureDeviceInput1 = try AVCaptureDeviceInput(device: captureDevice!)
                captureSession!.addInput(captureDeviceInput1)
            }
        }catch{
            print(error.localizedDescription)
        }
    }

    func turnFlashOn(){
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            try device.setTorchModeOn(level: 1.0)
            flashButton?.setImage(flashImage, for: .normal)
        } catch {
            print(error)
        }
    }

    func stopCapture(){
        if(captureSession != nil) {captureSession!.stopRunning()}
        if(videoPreviewLayer != nil) {videoPreviewLayer!.removeFromSuperlayer()}
        if(cancelButton != nil) {cancelButton!.removeFromSuperview()}
        if(flashButton != nil) {flashButton!.removeFromSuperview()}
        if(switchCameraButton != nil) {switchCameraButton!.removeFromSuperview()}

        captureSession = nil
        videoPreviewLayer = nil
        cancelButton = nil
        flashButton = nil
        switchCameraButton = nil
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
