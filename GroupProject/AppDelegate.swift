//
//  AppDelegate.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/23/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit
import GooglePlaces
import Parse

let defaults = UserDefaults.standard

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        let parseConfig = ParseClientConfiguration { (ParseMutableClientConfiguration) in
            
            ParseMutableClientConfiguration.applicationId = "trippinAppID"
            ParseMutableClientConfiguration.clientKey = "trippinMasterKey"
            ParseMutableClientConfiguration.server = "http://trippincodepath.herokuapp.com/parse"//"http://testparsebca.herokuapp.com/parse"
        }
        
        Parse.initialize(with: parseConfig)
        
        GMSPlacesClient.provideAPIKey("AIzaSyC11OQ4loHbjXLhOaQl-zXJWDPPGbLcgts")
        
        let hamburgerViewController = HamburgerViewController.sharedInstance

        window!.rootViewController = HamburgerViewController.sharedInstance
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        
        menuViewController.hamburgerViewController = hamburgerViewController
        
        hamburgerViewController.menuViewController = menuViewController
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        Globals.saveContext()
    }
}

