//
//  BestTimesToTravelViewController.swift
//  WSDOT
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

class BestTimesToTravelDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let chartCellIdentifier = "TravelChartCell"

    var routeItem: BestTimesToTravelRouteItem = BestTimesToTravelRouteItem(name: "error", charts: [])
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = routeItem.name
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Traffic Map/Traveler Information/Best Times To Travel Routes/Details")
    }
    
    // MARK: -
    // MARK: Table View Data source methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // TODO Make groups for each route
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeItem.charts.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
 
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: chartCellIdentifier) as! TravelChartImageCell
        
        // Add timestamp to help prevent caching
        let urlString = routeItem.charts[indexPath.row].url + "?" + String(Int(Date().timeIntervalSince1970 / 60))
        cell.ChartImage.sd_setImage(with: URL(string: urlString), placeholderImage: UIImage(named: "imagePlaceholder"), options: [.cacheMemoryOnly, .scaleDownLargeImages])
        cell.accessibilityLabel = routeItem.charts[indexPath.row].altText
        return cell
    }

}

