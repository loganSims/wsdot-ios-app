//
//  CalloutViewController.swift
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

class CalloutViewController: UIViewController {

    @IBOutlet weak var calloutImageView: UIImageView!
    var calloutURL = ""
    
    override func viewDidAppear(animated: Bool) {
        calloutImageView.sd_setImageWithURL(NSURL(string: calloutURL), placeholderImage: UIImage(named: "imagePlaceholder"), options: .RefreshCached)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Traffic Map/JBLM Flow Map")
    }
}