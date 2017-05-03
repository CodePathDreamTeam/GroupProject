//
//  MenuViewController.swift
//  HamburgerMenu
//
//  Created by Brandon on 4/17/17.
//  Copyright © 2017 Brandon. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var homeNavController: UINavigationController!
    private var todoNavController: UINavigationController!
    private var financesNaveController: UINavigationController!
    private var weatherStationNavController: UINavigationController!
    private var poisNavController: UINavigationController!
    private var photoMapNavController: UINavigationController!
    private var theWallNavController: UINavigationController!

    
    var viewControllers: [UIViewController] = []
    var hamburgerViewController: HamburgerViewController!
    let titles = ["Home","To-Do","Finances","Weather Station","Points of interest/Augmented","Save Photo with location Station","Virtual wall"]

    
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = titles[indexPath.row]
        
        return cell
    }
}
