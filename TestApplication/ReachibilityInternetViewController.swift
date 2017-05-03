////
////  ReachibilityInternetViewController.swift
////  TestApplication
////
////  Created by AzinecLLC on 3/23/17.
////  Copyright © 2017 AzinecLLC. All rights reserved.
////
//
//import UIKit
//import SystemConfiguration
//
//var reachability = Reachability()
//
//class ReachibilityInternetViewController: UIViewController {
//    
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityStatusChanged(_:)), name: .reachabilityChanged, object: nil)
//        
//    }
//    
//    func updateInterfaceWithCurrent(networkStatus: NetworkStatus) {
//        switch networkStatus {
//        case NotReachable:
//            view.backgroundColor = .red
//            print("No Internet")
//        case ReachableViaWiFi:
//            view.backgroundColor = .green
//            print("Reachable Internet")
//        case ReachableViaWWAN:
//            view.backgroundColor = .yellow
//            print("Reachable Cellular")
//        default:
//            return
//        }
//        
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        //
//        updateInterfaceWithCurrent(networkStatus: reachability.currentReachabilityStatus())
//        
//    }
//    func reachabilityStatusChanged(_ sender: NSNotification) {
//        guard let networkStatus = (sender.object as? Reachability)?.currentReachabilityStatus() else { return }
//        updateInterfaceWithCurrent(networkStatus: networkStatus)
//    }
//    override func viewWillDisappear(_ animated: Bool) {
//        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
