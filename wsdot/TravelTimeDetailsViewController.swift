//
//  TravelTimeDetailsViewController.swift
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

class TravelTimeDetailsViewController: UIViewController {

    @IBOutlet weak var favoriteTabBarButton: UIBarButtonItem!
    @IBOutlet weak var routeTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var updated: UILabel!
    @IBOutlet weak var currentTime: UILabel!

    var travelTimeGroup = TravelTimeItemGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        title = travelTime.title

        routeTitle.text = travelTime.title
        subTitle.text = String(travelTime.distance) + " miles / " + String(travelTime.averageTime) + " min"
        
        do {
            let updatedText = try TimeUtils.timeAgoSinceDate(date: TimeUtils.formatTimeStamp(travelTime.updated), numericDates: false)
            updated.text = updatedText
        } catch TimeUtils.TimeUtilsError.invalidTimeString {
            updated.text = "N/A"
        } catch {
            updated.text = "N/A"
        }
        
        if travelTime.currentTime == 0{
            currentTime.text = "N/A"
        } else {
            currentTime.text = String(travelTime.currentTime) + " min"
        }
 
        if (travelTime.averageTime > travelTime.currentTime){
            currentTime.textColor = Colors.tintColor
        } else if (travelTime.averageTime < travelTime.currentTime){
            currentTime.textColor = UIColor.red
        } else {
            currentTime.textColor = UIColor.darkText
        }
        
        if (travelTime.selected){
            favoriteTabBarButton.image = UIImage(named: "icStarSmallFilled")
        }else{
            favoriteTabBarButton.image = UIImage(named: "icStarSmall")
        }
        
        favoriteTabBarButton.tintColor = Colors.yellow
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Travel Time Details")
    }
    
    @IBAction func updateFavorite(_ sender: UIBarButtonItem) {
    /*
        if (travelTime.selected){
            TravelTimesStore.updateFavorite(travelTime, newValue: false)
            favoriteTabBarButton.image = UIImage(named: "icStarSmall")
        }else {
            TravelTimesStore.updateFavorite(travelTime, newValue: true)
            favoriteTabBarButton.image = UIImage(named: "icStarSmallFilled")
        }
        */
    }
}
