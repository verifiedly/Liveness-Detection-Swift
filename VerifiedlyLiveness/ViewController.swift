//
//  ViewController.swift
//  VerifiedlyLiveness
//
//  Created by Samuel Ailemen on 8/22/21.
//

import UIKit

class ViewController: UIViewController {

    let liveness = VerifiedlyLivenessViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the Variables here
        liveness.apiKEY = "YOUR_API_KEY"
        
        //OPTIONAL
        //Change background and button colors
        liveness.background_color = "#f5f6fa"
        liveness.button_color = "#3742fa"
        
        //Enable Feedback vibration
        liveness.enable_vibration = true
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        liveness.onComplete = { message, pass, success  in
            print(message) // Success or error message
            print(pass) // Passed or Failed the liveness detection ( Will be false by default if success is false )
            print(success) // Determine if the request was successful or not
        }
        
        liveness.onExit = { result in
            print(result) //Triggered when the user dismisses the liveness detection screen
        }
    }
    
    
    @IBAction func startLiveness(_ sender: Any) {
        liveness.modalTransitionStyle = .crossDissolve
        liveness.modalPresentationStyle = .fullScreen
        self.present(liveness, animated: true, completion: nil)
    }
    
}

