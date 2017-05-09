//
//  MenuViewController.swift
//  HamburgerMenu
//
//  Created by Brandon on 4/17/17.
//  Copyright © 2017 Brandon. All rights reserved.
//

import UIKit
import CoreData

class MenuViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var homeNavController: UINavigationController!
    private var todoNavController: UINavigationController!
    private var financesNaveController: UINavigationController!
    private var weatherStationNavController: UINavigationController!
    private var poisNavController: UINavigationController!
    private var photoMapNavController: UINavigationController!
    private var theWallNavController: UINavigationController!

    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var greetingLabel: UILabel!
    
    var viewControllers: [UIViewController] = []
    var hamburgerViewController: HamburgerViewController!
    let titles = ["Home","To-Do","Finances","Weather","Near Me","Photo Map","Geo Journal"]
    let icons = [#imageLiteral(resourceName: "home"),#imageLiteral(resourceName: "checkbox"),#imageLiteral(resourceName: "calculator"),#imageLiteral(resourceName: "weather"),#imageLiteral(resourceName: "pin"),#imageLiteral(resourceName: "camera"),#imageLiteral(resourceName: "message")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)
        let todoStoryboard = UIStoryboard(name: "Todo", bundle: nil)
        let financesStoryboard = UIStoryboard(name: "Finances", bundle: nil)
        let weatherStationStoryboard = UIStoryboard(name: "WeatherStation", bundle: nil)
        let poisStoryboard = UIStoryboard(name: "Pois", bundle: nil)
        let photoMapStoryboard = UIStoryboard(name: "PhotoMap", bundle: nil)
        let theWallStoryboard = UIStoryboard(name: "TheWall", bundle: nil)

        homeNavController = homeStoryboard.instantiateInitialViewController() as! UINavigationController
        todoNavController = todoStoryboard.instantiateInitialViewController() as! UINavigationController
        financesNaveController = financesStoryboard.instantiateInitialViewController() as! UINavigationController
        weatherStationNavController = weatherStationStoryboard.instantiateInitialViewController() as! UINavigationController
        poisNavController = poisStoryboard.instantiateInitialViewController() as! UINavigationController
        photoMapNavController = photoMapStoryboard.instantiateInitialViewController() as! UINavigationController
        theWallNavController = theWallStoryboard.instantiateInitialViewController() as! UINavigationController

        viewControllers.append(homeNavController)
        viewControllers.append(todoNavController)
        viewControllers.append(financesNaveController)
        viewControllers.append(weatherStationNavController)
        viewControllers.append(poisNavController)
        viewControllers.append(photoMapNavController)
        viewControllers.append(theWallNavController)
        
        hamburgerViewController.contentViewController = homeNavController
        
        //loadFromCoreData()
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let savedName = UserDefaults.standard.string(forKey: "name") ?? "Traveler"
        greetingLabel.text = "Greetings, \(savedName)!"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadFromCoreData() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "UserPhoto")
        let result = Globals.fetch(request)
        if result.isSuccess {
            
            let fetchedPhotoData = result.value!
            print(fetchedPhotoData.count)
            if let photoData = fetchedPhotoData[0] as? UserPhoto {
                if let userPhotoData = photoData.photoImage as Data? {
                    userPhotoImageView.image = UIImage(data: userPhotoData)
                }
            }
        } else {
            print("PhotoMapViewController.loadFromCoreData Error: \(String(describing: result.error?.localizedDescription))")
        }
    }

}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        hamburgerViewController.contentViewController = viewControllers[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
//        cell.textLabel?.text = titles[indexPath.row]
        cell.cellLabel?.text = titles[indexPath.row]
        cell.iconImageView?.image = icons[indexPath.row]
        
        return cell
    }
}

extension MenuViewController: SettingsViewControllerDelegate {
    
    func settingsViewController(didUpdatePhoto photo: UIImage) {
        userPhotoImageView.image = photo
    }
    
    func settingsViewController(didUpdateName: String) {
        let savedName = UserDefaults.standard.string(forKey: "name") ?? "Traveler"
        greetingLabel.text = "Greetings, \(savedName)!"
    }
}
