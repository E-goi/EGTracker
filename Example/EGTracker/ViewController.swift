//
//  ViewController.swift
//  EGTracker
//
//  Created by Miguel Chaves on 04/01/2016.
//  Copyright (c) 2016 Miguel Chaves. All rights reserved.
//

import UIKit
import EGTracker

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        EGTracker.sharedInstance.trackEvent(EGEvents.viewHome)
    }
    
    @IBAction func trackButtonAction() {
        EGTracker.sharedInstance.trackEvent(EGEvents.eventButton)
    }
}

