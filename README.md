# Verifiedly's Passive Liveness detection for IOS

## Getting started

Before you attempt to use this passive liveness detection in your application, you'll need to get an API key from [Here](https://account.verified.ly).
Understand that you will need to hold a positive account balance for any request to go through.


## Installation

1. Drag and drop the Sources folder in your Xcode project.
2. Install [Alamofire](https://github.com/Alamofire/Alamofire) and [SwiftJSON](https://github.com/swiftjson/SwiftJson)

``` Swift
 pod 'Alamofire'
 pod 'SwiftyJSON'
```

3. In the Viewcontroller where you plan to initialize the liveness detection 

``` Swift
    let liveness = VerifiedlyLivenessViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the Variables here
        liveness.apiKEY = "YOUR_API_KEY"
        
        //OPTIONAL
        //Change background and button colors
        liveness.background_color = "#f5f6fa"
        liveness.button_color = "#3742fa"
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
```

4. Begin the liveness detection
``` Swift
//Assuming you are calling the Verifiedly Liveness Detection with a button
    @IBAction func startLiveness(_ sender: Any) {
        liveness.modalTransitionStyle = .crossDissolve
        liveness.modalPresentationStyle = .fullScreen
        self.present(liveness, animated: true, completion: nil)
    }
```

### Full Documentation
If you are looking for a full documentation and API reference, check out [HERE](https://www.verifiedlydocs.com/facial_recognition_liveness/liveness.html)
