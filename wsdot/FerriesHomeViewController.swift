//
//  FerriesHomeTableViewController.swift
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

class FerriesHomeViewController: UITableViewController {

    let cellIdentifier = "FerriesHomeCell"
    let SegueRouteSchedulesViewController = "RouteSchedulesViewController"
    let SegueVesselWatchViewController = "VesselWatchViewController"
    
    var menu_options: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        menu_options = ["Route Schedules", "Vehicle Reservations Website", "VesselWatch"]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Ferries")
    }

    // MARK: Table View Data Source Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu_options.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        // Configure Cell
        cell.textLabel?.text = menu_options[indexPath.row]
     
        return cell
    }
    
    // MARK: Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Perform Segue
        switch (indexPath.row) {
        case 0:
            performSegue(withIdentifier: SegueRouteSchedulesViewController, sender: self)
            break
        case 1:
            GoogleAnalytics.screenView(screenName: "/Ferries/Vehicle Reservations")
            UIApplication.shared.openURL(URL(string: "https://secureapps.wsdot.wa.gov/Ferries/Reservations/Vehicle/default.aspx")!)
            break
        case 2:
            UserDefaults.standard.set(47.565125, forKey: UserDefaultsKeys.mapLat)
            UserDefaults.standard.set(-122.480508, forKey: UserDefaultsKeys.mapLon)
            UserDefaults.standard.set(11, forKey: UserDefaultsKeys.mapZoom)
            performSegue(withIdentifier: SegueVesselWatchViewController, sender: self)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
