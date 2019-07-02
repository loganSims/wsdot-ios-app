//
//  MountainPassCamerasViewController.swift
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

import Foundation
import UIKit
import GoogleMobileAds

class MountainPassCamerasViewController: RefreshViewController, UITableViewDataSource, UITableViewDelegate, GADBannerViewDelegate {
    
    let camerasCellIdentifier = "PassCamerasCell"
    let SegueCamerasViewController = "CamerasViewController"
    
    let refreshControl = UIRefreshControl()
    
    var passItem : MountainPassItem = MountainPassItem()
    
    var cameras : [CameraItem] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: DFPBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mountainPassTabBarContoller = self.tabBarController as! MountainPassTabBarViewController
        passItem = mountainPassTabBarContoller.passItem
        
        tableView.rowHeight = UITableView.automaticDimension
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(MountainPassCamerasViewController.refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        self.tableView.contentOffset = CGPoint(x: 0, y: -self.refreshControl.frame.size.height)
        showOverlay(self.view)
        refresh(false)
        
        // Ad Banner
        bannerView.adUnitID = ApiKeys.getAdId()
        bannerView.rootViewController = self
        let request = DFPRequest()
        request.customTargeting = ["wsdotapp":"passes"]
        
        bannerView.load(request)
        bannerView.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "PassCameras")
    }
    
    @objc func refreshAction(_ refreshControl: UIRefreshControl) {
        refresh(true)
    }
    
    func refresh(_ force: Bool) {
        DispatchQueue.global().async {[weak self] in
            CamerasStore.updateCameras(force, completion: { error in
                if (error == nil){
                    DispatchQueue.main.async {[weak self] in
                        if let selfValue = self{
                        
                            var ids = [Int]()
                            for camera in selfValue.passItem.cameraIds{
                                ids.append(camera.cameraId)
                            }
                            selfValue.cameras = CamerasStore.getCamerasByID(ids)
                            selfValue.tableView.reloadData()
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                        }
                    }
                }else{
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                            AlertMessages.getConnectionAlert(backupURL: WsdotURLS.passes)
                        }
                    }
                }
            })
        }
    }
    
    // MARK: -
    // MARK: Table View Data source methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cameras.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: camerasCellIdentifier) as! CameraImageCustomCell
        
        // Add timestamp to help prevent caching
        let urlString = cameras[indexPath.row].url + "?" + String(Int(Date().timeIntervalSince1970 / 60))
        
        cell.CameraImage.sd_setImage(with: URL(string: urlString), placeholderImage: UIImage(named: "imagePlaceholder"), options: .refreshCached, completed: { image, error, cacheType, imageURL in
            if (error != nil) {
                cell.CameraImage.image = UIImage(named: "cameraOffline")
            }
        })
 
        return cell
    }
    
    // MARK: -
    // MARK: Table View Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Perform Segue
        performSegue(withIdentifier: SegueCamerasViewController, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueCamerasViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let cameraItem = self.cameras[indexPath.row] as CameraItem
                let destinationViewController = segue.destination as! CameraViewController
                destinationViewController.cameraItem = cameraItem
                destinationViewController.adTarget = "passes"
            }
        }
    }
}
