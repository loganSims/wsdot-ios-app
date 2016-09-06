//
//  HomeViewController.swift
//  wsdot
//
//  Copyright (c) 2016 Washington State Department of Transportation
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellIdentifier = "HomeCell"
    
    let SegueTrafficMapViewController = "TrafficMapViewController"
    let SegueFerriesHomeViewController = "FerriesHomeViewController"
    let SegueTollRatesViewController = "TollRatesViewController"
    let SegueBorderWaitsViewController = "BorderWaitsViewController"
    let SegueInfoViewController = "InfoViewController"
    let SegueMountainPassesViewController = "MountainPassesViewController"
    let SegueSocialMediaViewController = "SocialMediaViewController"
    let SegueAmtrakCascadesViewController = "AmtrakCascadesViewController"
    
    var menu_options: [String] = []
    var menu_icon_names: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Title
        title = "WSDOT"
        menu_options = ["Traffic Map", "Ferries", "Mountain Passes", "Social Media", "Toll Rates", "Border Waits", "Amtrak Cascades"]
        menu_icon_names = ["icHomeTraffic","icHomeFerries","icHomePasses","icHomeSocialMedia","icHomeTollRates","icHomeBorderWaits","icHomeAmtrakCascades"]
        
        self.tabBarController!.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Home")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Initialize Tab Bar Item
        tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "ic-home"), tag: 0)
    }
    @IBAction func infoBarButtonPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier(SegueInfoViewController, sender: self)
    }
    
    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu_options.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! IconCell
        
        cell.label?.text = menu_options[indexPath.row]
        cell.iconView.image = UIImage(named: menu_icon_names[indexPath.row])
        
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Perform Segue
        switch (indexPath.row) {
        case 0:
            performSegueWithIdentifier(SegueTrafficMapViewController, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
        case 1:
            performSegueWithIdentifier(SegueFerriesHomeViewController, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
        case 2:
            performSegueWithIdentifier(SegueMountainPassesViewController, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
        case 3:
            performSegueWithIdentifier(SegueSocialMediaViewController, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
        case 4:
            performSegueWithIdentifier(SegueTollRatesViewController, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
        case 5:
            performSegueWithIdentifier(SegueBorderWaitsViewController, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
        case 6:
            performSegueWithIdentifier(SegueAmtrakCascadesViewController, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
        default:
            break
        }
    }
}
