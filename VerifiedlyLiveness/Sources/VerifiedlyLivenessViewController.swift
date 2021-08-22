//
//  VerifiedlyLivenessViewController.swift
//  VerifiedlyLiveness
//
//  Created by Samuel Ailemen on 8/22/21.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON

class VerifiedlyLivenessViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    public var onComplete: ((_ message: String, _ pass: Bool, _ success: Bool)->())?
    public var onExit: ((_ result: String)->())?
    public var button_color = "5f27cd"
    public var background_color = "F5F5F5"
    public var apiKEY = ""
    //Declare camera objects
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = hexStringToUIColor(hex: background_color)
        setButton()
        setCancelBtn()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        //Gain access to the front camera
        guard let device = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .front) else {return}

        do {
            let input = try AVCaptureDeviceInput(device: device)
            stillImageOutput = AVCapturePhotoOutput()

            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setCameraView()
            }
            
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
        }
        
  
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    

    func setButton() {
        //Create and Style the button
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.backgroundColor = hexStringToUIColor(hex: button_color)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Continue", for: .normal)
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        self.view.addSubview(button)
        //Set up the constraints
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    func setCancelBtn() {
        //Create and Style the button
        let button = UIButton()
        button.clipsToBounds = true
        button.setBackgroundImage(UIImage(named: "cancel_ver"), for: .normal)
        button.addTarget(self, action: #selector(exitAction(_:)), for: .touchUpInside)
        self.view.addSubview(button)
        //Set up the constraints
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    
    

    
    func setCameraView () {
        let previewLayer = UIView()
        previewLayer.frame.size.height = 479
        previewLayer.frame.size.width = 374
        previewLayer.layer.cornerRadius = 10
        previewLayer.clipsToBounds = true
        previewLayer.backgroundColor = .white
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewLayer.layer.addSublayer(videoPreviewLayer)
        DispatchQueue.main.async {
            self.videoPreviewLayer.frame = previewLayer.bounds
        }
        self.view.addSubview(previewLayer)
        //Set up the constraints
        previewLayer.translatesAutoresizingMaskIntoConstraints = false
        previewLayer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        previewLayer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70).isActive = true
        previewLayer.heightAnchor.constraint(equalToConstant: view.frame.height - 400).isActive = true
        previewLayer.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        
    }
    
    //Capture the photo
    @objc func buttonAction(_ sender:UIButton!) {
            if #available(iOS 11.0, *) {
                let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
                stillImageOutput.capturePhoto(with: settings, delegate: self)
            } else {
                // Fallback on earlier versions
            }
    }
    
    //Dismiss the Liveness View
    @objc func exitAction(_ sender:UIButton!) {
        self.onExit?("User Dismissed the Liveness View")
        self.dismiss(animated: false, completion: nil)
    }


    
    //Handle captured photo
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
        else { return }
        
        let image = UIImage(data: imageData)
        print(image!)
        self.captureSession.stopRunning()
            
        //Make a request to verifiedly servers
        self.addFace(selectedImg: imageData)
    }
    
    
    func addFace(selectedImg: Data) {
        let headers: HTTPHeaders = [
            "Content-Type": "multipart/form-data"
        ]
        let parameters: Parameters = [
            "apiKEY": apiKEY]

    AF.upload(multipartFormData: { (multipartFormData) in
        multipartFormData.append(selectedImg, withName: "document", fileName: "face.png", mimeType: "image/png")
        for (key, value) in parameters {
            multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
        }
    }, to: "https://api.verified.ly/v1/liveness", method: .post, headers: headers).responseJSON { response in
                        switch response.result {

                        case .success:
                            if response.response?.statusCode == 200 {
                                //The request was successful
                                let json = try? JSON(data: response.data!)
                                let result = json!["result"]
                                guard let real = result["real"].bool else {return}
                                self.onComplete?("Liveness detection complete", real, true)
                                self.dismiss(animated: false, completion: nil)
                            } else {
                                //The request failed
                                let json = try? JSON(data: response.data!)
                                guard let message = json!["message"].string else {return}
                                self.onComplete?(message, false, false)
                                self.dismiss(animated: false, completion: nil)
                            
                            }
                            break

                        case .failure:
                           
                            print("Error getting a response")
                            break

                        }
        }
    }
    
    //We need to disable landscape for this view
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return.portrait
    }
    
    //Convert hex code to uicolor
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
