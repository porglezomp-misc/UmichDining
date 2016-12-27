//
//  DiningHall.swift
//  umich-dining
//
//  Created by Caleb Jones on 12/26/16.
//  Copyright © 2016 Caleb Jones. All rights reserved.
//

import Foundation
import CoreLocation

let Barbour = DiningHall("Barbour Dining Hall")
let Bursley = DiningHall("Bursley Dining Hall")
let EastQuad = DiningHall("East Quad Dining Hall")
let MosherJordan = DiningHall("Mosher Jordan Dining Hall")
let Markley = DiningHall("Markley Dining Hall")
let NorthQuad = DiningHall("North Quad Dining Hall")
let SouthQuad = DiningHall("South Quad Dining Hall")
let Twigs = DiningHall("Twigs at Oxford")
let WestQuad = DiningHall("West Quad Dining Hall")

private let baseUrl: URL = URL(string: "http://www.housing.umich.edu/files/helper_files/js/menu2xml.php")!

class DiningHall {
    var name: String
    var menu: Menu? = nil
    
    // TODO: Addresses / lat-lon
    
    init(_ name: String) {
        self.name = name
    }

    func fetchMenu(date: Date? = nil, completion: @escaping (DiningHall) -> ()) {
        let queue = DispatchQueue(label: "net.calebjones.fetch-menu")
        queue.async {
            if let hall = self.blockingFetchMenu() {
                completion(hall)
            }
        }
    }
    
    func blockingFetchMenu(date: Date? = nil) -> DiningHall? {
        guard let name = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            else { return nil }
        
        var urlString = baseUrl.absoluteString + "?=\(name)"
        if let date = date {
            urlString += "&date=\(date)"
        }
        guard let url = URL(string: urlString)
            else { return nil }
        
        guard let xml = XMLParser(contentsOf: url)
            else { return nil }
        
        if let obj = DiningHallParser().parse(parser: xml) {
            self.name = obj.name
        }
        return self
    }
    
    static func fetchDiningHalls(completion: @escaping ([DiningHall]) -> ()) {
        let queue = DispatchQueue(label: "net.calebjones.fetch-dining-halls")
        queue.async {
            if let halls = self.blockingFetchDiningHalls() {
                completion(halls)
            }
        }
    }
    
    static func blockingFetchDiningHalls() -> [DiningHall]? {
        guard let xml = XMLParser(contentsOf: baseUrl)
            else { return nil }
        return DiningHallListParser().parse(parser: xml)
    }
}
