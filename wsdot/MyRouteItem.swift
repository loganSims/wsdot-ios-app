//
//  MyRouteItem.swift
//  WSDOT
//
//  Copyright (c) 2017 Washington State Department of Transportation
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
import RealmSwift

class MyRouteItem: Object {
    
    dynamic var id = 1
    dynamic var name = ""
    
    dynamic var foundTravelTimes = false
    dynamic var foundCameras = false
    dynamic var foundMountainPasses = false
    dynamic var foundFerrySchedules = false
    
    dynamic var displayLatitude = 0.0
    dynamic var displayLongitude = 0.0
    dynamic var displayZoom = 0.0
    
    dynamic var selected = false
    
    let route = List<MyRouteLocationItem>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}