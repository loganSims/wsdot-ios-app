//
//  MountainPassesViewController.swift
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
import Foundation
import GoogleMobileAds

class MountainPassesViewController: RefreshViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {

    let cellIdentifier = "PassCell"
    let segueMountainPassDetailsViewController = "MountainPassDetailsViewController"
    
    var passItems = [MountainPassItem]()

    @IBOutlet weak var bannerView: DFPBannerView!
    
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // refresh controller
        refreshControl.addTarget(self, action: #selector(MountainPassesViewController.refreshAction(_:)), for: .valueChanged)
        
        tableView.addSubview(refreshControl)
        
        showOverlay(self.view)
        
        self.passItems = MountainPassStore.getPasses()
        self.tableView.reloadData()
        
        refresh(false)
        tableView.rowHeight = UITableView.automaticDimension
        
        // Ad Banner
        bannerView.adUnitID = ApiKeys.getAdId()
        bannerView.adSize = getFullWidthAdaptiveAdSize()
        bannerView.rootViewController = self
        let request = DFPRequest()
        request.customTargeting = ["wsdotapp":"passes"]
        bannerView.load(request)
        bannerView.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "PassReports")
    }
    
    func refresh(_ force: Bool){
      DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            MountainPassStore.updatePasses(force, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.passItems = MountainPassStore.getPasses()
                            selfValue.tableView.reloadData()
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: selfValue.tableView)
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                            AlertMessages.getConnectionAlert(backupURL: WsdotURLS.passes, message: WSDOTErrorStrings.passReports)
                        }
                    }
                }
            })
        }
    }
    
    @objc func refreshAction(_ sender: UIRefreshControl) {
        refresh(true)
    }

    // MARK: Table View Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! MountainPassCell
        
        let passItem = passItems[indexPath.row]
        
        cell.nameLabel.text = passItem.name
        
        cell.forecastLabel.text = ""
        
        if (passItem.weatherCondition != ""){
            cell.forecastLabel.text = passItem.weatherCondition
        }
        
        if (passItem.forecast.count > 0){
            if (cell.forecastLabel.text == "") {
                cell.forecastLabel.text = WeatherUtils.getForecastBriefDescription(passItem.forecast[0].forecastText)
            }
            cell.weatherImage.image = UIImage(named: WeatherUtils.getIconName(passItem.forecast[0].forecastText, title: passItem.forecast[0].day))
        } else {
            cell.forecastLabel.text = ""
            cell.weatherImage.image = nil
        }
        
        if passItem.dateUpdated as Date == Date.init(timeIntervalSince1970: 0){
            cell.updatedLabel.text = "Not Available"
        }else {
            cell.updatedLabel.text = TimeUtils.timeAgoSinceDate(date: passItem.dateUpdated, numericDates: true)
        }
     
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Perform Segue
        performSegue(withIdentifier: segueMountainPassDetailsViewController, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueMountainPassDetailsViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let passItem = self.passItems[indexPath.row] as MountainPassItem
                let destinationViewController = segue.destination as! MountainPassTabBarViewController
                destinationViewController.passItem = passItem
                let backItem = UIBarButtonItem()
                backItem.title = "Back"
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
}
