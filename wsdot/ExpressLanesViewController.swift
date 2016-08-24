//
//  ExpressLanesViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/23/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit

class ExpressLanesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "ExpressLanesCell"
    let webLinkcellIdentifier = "WebsiteLinkCell"
    
    @IBOutlet weak var tableView: UITableView!
    var expressLanes = [ExpressLaneItem]()
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        
        title = "Express Lanes"
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(ExpressLanesViewController.refresh(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        refreshControl.beginRefreshing()
        refresh(self.refreshControl)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }

    func refresh(refreshControl: UIRefreshControl) {
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { [weak self] in
            ExpressLanesStore.getExpressLanes({ data, error in
                if let validData = data {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.expressLanes = validData
                            selfValue.tableView.reloadData()
                            selfValue.refreshControl.endRefreshing()
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.refreshControl.endRefreshing()
                            selfValue.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }

    // MARK: Table View Data Source Methods
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expressLanes.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.row == expressLanes.count){
            let cell = tableView.dequeueReusableCellWithIdentifier(webLinkcellIdentifier, forIndexPath: indexPath)
            cell.textLabel?.text = "Express Lanes Schedule Website"
            cell.accessoryType = .DisclosureIndicator
            cell.selectionStyle = .Blue
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! ExpressLaneCell
            cell.routeLabel.text = expressLanes[indexPath.row].route
            cell.directionLabel.text = expressLanes[indexPath.row].direction
            cell.updatedLabel.text = TimeUtils.timeAgoSinceDate(TimeUtils.formatTimeStamp(expressLanes[indexPath.row].updated), numericDates: false)
            cell.selectionStyle = .None
            return cell
        }
    }
    
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row) {
        case expressLanes.count:
            UIApplication.sharedApplication().openURL(NSURL(string: "http://www.wsdot.wa.gov/Northwest/King/ExpressLanes")!)
            break
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}