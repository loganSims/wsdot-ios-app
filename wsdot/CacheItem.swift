//
//  CachesRealmDataModel.swift
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
import RealmSwift

class CacheItem: Object{
    @objc dynamic var id = 0
    
    @objc dynamic var travelTimesLastUpdate: Date = Date(timeIntervalSince1970: 0)
    @objc dynamic var highwayAlertsLastUpdate: Date = Date(timeIntervalSince1970: 0)
    @objc dynamic var ferriesLastUpdate: Date = Date(timeIntervalSince1970: 0)
    @objc dynamic var camerasLastUpdate: Date = Date(timeIntervalSince1970: 0)
    @objc dynamic var borderWaitsLastUpdate: Date = Date(timeIntervalSince1970: 0)
    @objc dynamic var mountainPassesLastUpdate: Date = Date(timeIntervalSince1970: 0)
    @objc dynamic var notificationsLastUpdate: Date = Date(timeIntervalSince1970: 0)
    @objc dynamic var tollRatesLastUpdate: Date = Date(timeIntervalSince1970: 0)
    @objc dynamic var staticTollRatesLastUpdate: Date = Date(timeIntervalSince1970: 0)
    @objc dynamic var bridgeAlertsLastUpdate: Date = Date(timeIntervalSince1970: 0)
    
    override class func primaryKey() -> String {
        return "id"
    }
}

