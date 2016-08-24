//
//  CameraViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/2/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    
    @IBOutlet weak var cameraImage: UIImageView!
    @IBOutlet weak var favoriteBarButton: UIBarButtonItem!
    
    var cameraItem: CameraItem = CameraItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = cameraItem.title;
        
        cameraImage.sd_setImageWithURL(NSURL(string: cameraItem.url), placeholderImage: UIImage(named: "imagePlaceholder"), options: .RefreshCached)
        
        if (cameraItem.selected){
            favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
        }else{
            favoriteBarButton.image = UIImage(named: "icStarSmall")
        }
    }
    
    @IBAction func updateFavorite(sender: UIBarButtonItem) {
        if (cameraItem.selected){
            CamerasStore.updateFavorite(cameraItem, newValue: false)
            favoriteBarButton.image = UIImage(named: "icStarSmall")
        }else {
            CamerasStore.updateFavorite(cameraItem, newValue: true)
            favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
        }
    }
}
