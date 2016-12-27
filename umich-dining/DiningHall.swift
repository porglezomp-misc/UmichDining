//
//  DiningHall.swift
//  umich-dining
//
//  Created by Caleb Jones on 12/26/16.
//  Copyright © 2016 Caleb Jones. All rights reserved.
//

import Foundation
import CoreLocation
import Contacts

let barbour = DiningHall("Barbour Dining Hall")
let bursley = DiningHall("Bursley Dining Hall")
let eastQuad = DiningHall("East Quad Dining Hall")
let mosherJordan = DiningHall("Mosher Jordan Dining Hall")
let markley = DiningHall("Markley Dining Hall")
let northQuad = DiningHall("North Quad Dining Hall")
let southQuad = DiningHall("South Quad Dining Hall")
let twigs = DiningHall("Twigs at Oxford")
let westQuad = DiningHall("West Quad Dining Hall")

private let baseUrl: URL = URL(string: "http://www.housing.umich.edu/files/helper_files/js/menu2xml.php")!

class DiningHall {
    var name: String
    var menu: Menu = Menu()
    var contact: CNContact? = nil
    
    // TODO: Addresses / lat-lon
    
    init(_ name: String) {
        self.name = name
    }

    func fetchData(date: Date? = nil, completion: @escaping (DiningHall) -> ()) {
        let queue = DispatchQueue(label: "net.calebjones.fetch-menu")
        queue.async {
            if let hall = self.blockingFetchData() {
                completion(hall)
            }
        }
    }
    
    func blockingFetchData(date: Date? = nil) -> DiningHall? {
        guard let name = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            else { return nil }
        
        var urlString = baseUrl.absoluteString + "?location=\(name)"
        if let date = date {
            urlString += "&date=\(date)"
        }
        guard let url = URL(string: urlString)
            else { return nil }
        guard let data = try? Data(contentsOf: url)
            else { return nil }
        
        let xml = XMLParser(data: data)
        guard let obj = DiningHallParser().parse(parser: xml)
            else { return nil }

        self.name = obj.name
        self.menu = obj.menu
        self.contact = obj.contact
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
        guard let data = try? Data(contentsOf: baseUrl)
            else { return nil }
        let xml = XMLParser(data: data)
        return DiningHallListParser().parse(parser: xml)
    }
}
