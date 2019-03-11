//
//  MyRouteAlertsViewController.swift
//  WSDOT
//
//  Copyright (c) 2019 Washington State Department of Transportation
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
import RealmSwift
import SafariServices

class MyRouteReportViewController: UIViewController {

    var alerts = [HighwayAlertItem]()
    
    var trafficAlerts = [HighwayAlertItem]()
    var constructionAlerts = [HighwayAlertItem]()
    var specialEvents = [HighwayAlertItem]()
    
    var route: MyRouteItem?
    
    let cellIdentifier = "AlertCell"
    
    let segueHighwayAlertViewController = "HighwayAlertViewController"
    
    let segueMyRouteAlertViewController = "MyRouteAlertsViewController"
    let segueMyRouteCamerasViewController = "MyRouteCamerasViewControllers"
    let segueMyRouteTravelTimesViewController = "MyRouteTravelTimesViewController"
    
    let refreshControl = UIRefreshControl()
    var activityIndicator = UIActivityIndicatorView()

    fileprivate var alertMarkers = Set<GMSMarker>()

    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var alertsContainerView: UIView!
    @IBOutlet weak var camerasContainerView: UIView!
    @IBOutlet weak var travelTimesContainerView: UIView!
    
    var alertsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showOverlay(self.view)
        
        // Prepare Google mapView
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.isTrafficEnabled = true
        
        alertsContainerView.isHidden = false
        camerasContainerView.isHidden = true
        travelTimesContainerView.isHidden = true
        
        _ = drawRouteOnMap(Array(route!.route))
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "MyRouteAlerts")
    }

    @IBAction func segmentSelected(_ sender: UISegmentedControl) {
        
        switch (sender.selectedSegmentIndex) {
        
        case 0:
            alertsContainerView.isHidden = false
            camerasContainerView.isHidden = true
            travelTimesContainerView.isHidden = true
            break
        case 1:
            alertsContainerView.isHidden = true
            camerasContainerView.isHidden = true
            travelTimesContainerView.isHidden = false
            break
        case 2:
            alertsContainerView.isHidden = true
            camerasContainerView.isHidden = false
            travelTimesContainerView.isHidden = true
            break
        default:
            return
        }
        
    }
    
    @IBAction func settingsAction(_ sender: UIBarButtonItem) {
    
        MyAnalytics.event(category: "My Route", action: "UIAction", label: "Route Settings")
    
        let editController = (UIDevice.current.userInterfaceIdiom == .phone ?
              UIAlertController(title: "Settings", message: nil, preferredStyle: .actionSheet)
            : UIAlertController(title: "Settings", message: nil, preferredStyle: .alert) )
        
        editController.view.tintColor = Colors.tintColor
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (result : UIAlertAction) -> Void in
            //action when pressed button
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (result : UIAlertAction) -> Void in
        
            MyAnalytics.event(category: "My Route", action: "UIAction", label: "Delete Route")
        
            let alertController = UIAlertController(title: "Delete route \(self.route!.name)?", message:"This cannot be undone", preferredStyle: .alert)

            alertController.view.tintColor = Colors.tintColor

            let confirmDeleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) -> Void in
            
                MyAnalytics.event(category: "My Route", action: "UIAction", label: "Delete Route Confirmed")
                
                _ = MyRouteStore.delete(route: self.route!)
                
                self.navigationController?.popViewController(animated: true)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(confirmDeleteAction)
            
            self.present(alertController, animated: false, completion: nil)
        }
        
        let renameAction = UIAlertAction(title: "Rename", style: .default) { (result : UIAlertAction) -> Void in
        
            MyAnalytics.event(category: "My Route", action: "UIAction", label: "Rename Route")
        
            let alertController = UIAlertController(title: "Edit Name", message:nil, preferredStyle: .alert)
            alertController.addTextField { (textfield) in
                textfield.placeholder = self.route!.name
            }
            alertController.view.tintColor = Colors.tintColor

            let okAction = UIAlertAction(title: "Ok", style: .default) { (_) -> Void in
        
                let textf = alertController.textFields![0] as UITextField
                var name = textf.text!
                if name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" {
                    name = self.route!.name
                }
                
                _ = MyRouteStore.updateName(forRoute: self.route!, name)
                self.title = name
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: false, completion: nil)

        }
        
        editController.addAction(cancelAction)
        editController.addAction(deleteAction)
        editController.addAction(renameAction)
    
        self.present(editController, animated: true, completion: nil)
    
    }
    
    @objc func refreshAction(_ refreshController: UIRefreshControl){
        loadAlerts(force: true)
    }
    
    func loadAlerts(force: Bool){
        
        if route != nil {
            
            let serviceGroup = DispatchGroup();
            
            requestAlertsUpdate(force, serviceGroup: serviceGroup)
                
            serviceGroup.notify(queue: DispatchQueue.main) {
                
                self.constructionAlerts.removeAll()
                self.specialEvents.removeAll()
                self.trafficAlerts.removeAll()
                
                for alert in self.alerts{
                    if alert.headlineDesc.lowercased().contains("construction") || alert.eventCategory.lowercased().contains("construction") {
                        self.constructionAlerts.append(alert)
                    }else if alert.eventCategory.lowercased() == "special event"{
                        self.specialEvents.append(alert)
                    }else {
                        self.trafficAlerts.append(alert)
                    }
                }
                
                self.trafficAlerts = self.trafficAlerts.sorted(by: {$0.lastUpdatedTime.timeIntervalSince1970  > $1.lastUpdatedTime.timeIntervalSince1970})
                self.constructionAlerts = self.constructionAlerts.sorted(by: {$0.lastUpdatedTime.timeIntervalSince1970  > $1.lastUpdatedTime.timeIntervalSince1970})
                self.specialEvents = self.specialEvents.sorted(by: {$0.lastUpdatedTime.timeIntervalSince1970  > $1.lastUpdatedTime.timeIntervalSince1970})

                self.alertsTableView.rowHeight = UITableView.automaticDimension
                self.alertsTableView.reloadData()
                
                self.hideOverlayView()
                
                self.drawAlerts()
                
                self.refreshControl.endRefreshing()
            }
        }
    }
    

    fileprivate func requestAlertsUpdate(_ force: Bool, serviceGroup: DispatchGroup) {
        serviceGroup.enter()
        
        let routeRef = ThreadSafeReference(to: self.route!)
        
            HighwayAlertsStore.updateAlerts(force, completion: { error in
                if (error == nil){
                
                    let routeItem = try! Realm().resolve(routeRef)
                    let nearbyAlerts = MyRouteStore.getNearbyAlerts(forRoute: routeItem!, withAlerts: HighwayAlertsStore.getAllAlerts())
                    
                    self.alerts.removeAll()
                    
                    // copy alerts to unmanaged Realm object so we can access on main thread.
                    for alert in nearbyAlerts {
                        let tempAlert = HighwayAlertItem()
                        tempAlert.alertId = alert.alertId
                        tempAlert.county = alert.county
                        tempAlert.delete = alert.delete
                        tempAlert.endLatitude = alert.endLatitude
                        tempAlert.endLongitude = alert.endLongitude
                        tempAlert.endTime = alert.endTime
                        tempAlert.eventCategory = alert.eventCategory
                        tempAlert.eventStatus = alert.eventStatus
                        tempAlert.extendedDesc = alert.extendedDesc
                        tempAlert.headlineDesc = alert.headlineDesc
                        tempAlert.lastUpdatedTime = alert.lastUpdatedTime
                        tempAlert.priority = alert.priority
                        tempAlert.region = alert.region
                        tempAlert.startDirection = alert.startDirection
                        tempAlert.startLatitude = alert.startLatitude
                        tempAlert.startLongitude = alert.startLongitude
                        tempAlert.startTime = alert.startTime
                        self.alerts.append(tempAlert)
                    }

                    self.alerts = self.alerts.sorted(by: {$0.lastUpdatedTime.timeIntervalSince1970  > $1.lastUpdatedTime.timeIntervalSince1970})
                    
                    serviceGroup.leave()
                }else{
                    serviceGroup.leave()
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
    }
    
    /**
     * Method name: showOverlay
     * Description: creates an loading indicator in the center of the screen.
     * Parameters: view: The view to display the loading indicator on.
     */
    func showOverlay(_ view: UIView) {
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.style = .whiteLarge
        activityIndicator.color = UIColor.gray
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    /**
     * Method name: hideOverlayView
     * Description: Removes the loading overlay created in showOverlay
     */
    func hideOverlayView(){
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }

    // MARK: Naviagtion
    // Get refrence to child VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueHighwayAlertViewController {
            
            if let alertItem = (sender as? HighwayAlertItem) {
                let destinationViewController = segue.destination as! HighwayAlertViewController
            
                destinationViewController.alertId = alertItem.alertId
            }
            
            if let marker = sender as? GMSMarker {
            
                if let alertId = marker.userData as? Int {
            
                    let destinationViewController = segue.destination as! HighwayAlertViewController
                    destinationViewController.alertId = alertId
                }
            }
        } else if segue.identifier == segueMyRouteAlertViewController {
            if let destinationViewController = segue.destination as? MyRouteAlertsViewController {
                destinationViewController.alertDataDelegate = self
            }
        } else if segue.identifier == segueMyRouteCamerasViewController {
            if let destinationViewController = segue.destination as? MyRouteCamerasViewController {
                destinationViewController.route = self.route
            }
        } else if segue.identifier == segueMyRouteTravelTimesViewController {
            if let destinationViewController = segue.destination as? MyRouteTravelTimesViewController {
                destinationViewController.route = self.route
            }
        }
    }
}

// Acts as a delegate for the MyRouteAlertViewController
// so we can share alerts betweenn the two VCs
extension MyRouteReportViewController: AlertTableDataDelegate {
    func alertTableReady(_ tableView: UITableView) {
        
        self.alertsTableView = tableView
        
        self.alertsTableView.delegate = self
        self.alertsTableView.dataSource = self
        
        // refresh controller
        self.refreshControl.addTarget(self, action: #selector(MyRouteReportViewController.refreshAction(_:)), for: .valueChanged)
        self.alertsTableView.addSubview(refreshControl)
        
        self.loadAlerts(force: true)
        
    }
}

extension MyRouteReportViewController: GMSMapViewDelegate {

    // MARK: GMSMapViewDelegate
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {

        // Check for overlapping markers.
        var markers = alertMarkers
        markers.remove(marker)
 
        performSegue(withIdentifier: segueHighwayAlertViewController, sender: marker)
       
        return true
    }

    func drawAlerts(){
    
        // clear any old markers
        for marker in alertMarkers {
            marker.map = nil
        }
        
        alertMarkers.removeAll()
    
        for alert in self.alerts {
    
            let alertLocation = CLLocationCoordinate2D(latitude: alert.startLatitude, longitude: alert.startLongitude)
            let marker = GMSMarker(position: alertLocation)
            marker.snippet = "alert"
        
            marker.icon = UIHelpers.getAlertIcon(forAlert: alert)
        
            marker.userData = alert.alertId
            marker.map = mapView
        
            alertMarkers.insert(marker)
        }
    
    }

    /**
     * Method name: displayRouteOnMap()
     * Description: sets mapView camera to show all of the newly recording route if there is data.
     * Parameters: locations: Array of CLLocations that make up the route.
     */
    func drawRouteOnMap(_ route: [MyRouteLocationItem]) -> Bool {
        
        var locations = [CLLocation]()
        
        for location in route {
            locations.append(CLLocation(latitude: location.lat, longitude: location.long))
        }
        
        if let region = MyRouteStore.getRouteMapRegion(locations: locations) {
            
            // set Map Bounds
            let bounds = GMSCoordinateBounds(coordinate: region.nearLeft,coordinate: region.farRight)
            let camera = mapView.camera(for: bounds, insets:UIEdgeInsets.zero)
            mapView.camera = camera!
            
            let myPath = GMSMutablePath()
            
            for location in locations {
                myPath.add(location.coordinate)
            }
            
            let MyRoute = GMSPolyline(path: myPath)
            
            MyRoute.spans = [GMSStyleSpan(color: UIColor(red: 0, green: 0.6588, blue: 0.9176, alpha: 1))] /* #00a8ea */
            MyRoute.strokeWidth = 2
            MyRoute.map = mapView
            mapView.animate(toZoom: (camera?.zoom)! - 0.0)
        
            return true
        } else {
            return false
        }
    }
}

// MARK: - TableView
extension MyRouteReportViewController:  UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch(section){
        case 0:
            return "Traffic Incidents" + (self.title != "Alert" && (trafficAlerts.count == 0) ? " - None Reported": "")
        case 1:
            return "Construction"  + (self.title != "Alert" && (constructionAlerts.count == 0) ? " - None Reported": "")
        case 2:
            return "Special Events"  + (self.title != "Alert" &&  (specialEvents.count == 0) ? " - None Reported": "")
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch(section){
            
        case 0:
            return trafficAlerts.count
        case 1:
            return constructionAlerts.count
        case 2:
            return specialEvents.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! LinkCell
        

        var alert = HighwayAlertItem()
        
        switch indexPath.section {
            case 0:
            alert = trafficAlerts[indexPath.row]
            break
            case 1:
            alert = constructionAlerts[indexPath.row]
            break
            case 2:
            alert = specialEvents[indexPath.row]
            break
            default:
            break
        }
        
        let htmlStyleString = "<style>body{font-family: '\(cell.linkLabel.font.fontName)'; font-size:\(cell.linkLabel.font.pointSize)px;}</style>"
        var htmlString = ""
    
        cell.updateTime.text = TimeUtils.timeAgoSinceDate(date: alert.lastUpdatedTime, numericDates: false)
        htmlString = htmlStyleString + alert.headlineDesc
        
        let attrStr = try! NSMutableAttributedString(
            data: htmlString.data(using: String.Encoding.unicode, allowLossyConversion: false)!,
            options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        
        cell.linkLabel.attributedText = attrStr
        cell.linkLabel.delegate = self
        
        switch (alert.priority){
            
        case "highest":
            cell.backgroundColor = UIColor(red: 255/255, green: 232/255, blue: 232/255, alpha: 1.0) /* #ffe8e8 */
            break
        case "high":
            cell.backgroundColor = UIColor(red: 255/255, green: 244/255, blue: 232/255, alpha: 1.0) /* #fff4e8 */
            break
        default:
            cell.backgroundColor = UIColor(red: 255/255, green: 254/255, blue: 232/255, alpha: 1.0) /* #fffee8 */
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: segueHighwayAlertViewController, sender: alerts[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MyRouteReportViewController:  INDLinkLabelDelegate {
    func linkLabel(_ label: INDLinkLabel, didLongPressLinkWithURL URL: Foundation.URL) {
        let activityController = UIActivityViewController(activityItems: [URL], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    func linkLabel(_ label: INDLinkLabel, didTapLinkWithURL URL: Foundation.URL) {
        let svc = SFSafariViewController(url: URL, entersReaderIfAvailable: true)
        if #available(iOS 10.0, *) {
            svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
            svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
        } else {
            svc.view.tintColor = ThemeManager.currentTheme().mainColor
        }
        self.present(svc, animated: true, completion: nil)
    }
}
