//
//  DiningHall.swift
//  UmichDining
//
//  Created by Caleb Jones on 12/26/16.
//  Copyright © 2016 Caleb Jones. All rights reserved.
//

import Foundation
import CoreLocation
import Contacts


public struct DiningHalls {
    static let barbour = DiningHall("Pantry At Barbour")
    static let bursley = DiningHall("Bursley Dining Hall")
    static let eastQuad = DiningHall("East Quad Dining Hall")
    static let mosherJordan = DiningHall("Mosher Jordan Dining Hall")
    static let markley = DiningHall("Markley Dining Hall")
    static let northQuad = DiningHall("North Quad Dining Hall")
    static let southQuad = DiningHall("South Quad Dining Hall")
    static let twigs = DiningHall("Twigs at Oxford")
    static let westQuad = DiningHall("West Quad Dining Hall")
}

private let baseUrl: URL = URL(string: "http://www.housing.umich.edu/files/helper_files/js/menu2xml.php")!


func ==(lhs: DiningHall, rhs: DiningHall) -> Bool {
    return lhs.name == rhs.name && lhs.menu == rhs.menu // && lhs.contact == rhs.contact
}

class DiningHall: CustomDebugStringConvertible, Equatable {
    var name: String
    var menu: Menu = Menu()
    var contact: CNContact? = nil
    // TODO: lat-lon in the contact?
    
    init(_ name: String) {
        self.name = name
    }
    
    public var debugDescription: String {
        return "DiningHall(name: \(name), menu: \(menu), contact: \(contact))"
    }

    func fetchData(date: Date? = nil, completion: @escaping (DiningHall) -> ()) {
        let queue = DispatchQueue(label: "net.calebjones.fetch-menu")
        queue.async {
            if let hall = self.blockingFetchData(date: date) {
                completion(hall)
            }
        }
    }
    
    func blockingFetchData(date: Date? = nil) -> DiningHall? {
        guard let name = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            else { return nil }
        var urlString = baseUrl.absoluteString + "?location=\(name)"
        if let date = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            guard let date = dateFormatter.string(from: date).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                else {return nil}

            urlString += "&date=\(date)"
        }
        guard let url = URL(string: urlString)
            else { return nil }
        guard let data = try? Data(contentsOf: url)
            else { return nil }
        
        let xml = XMLParser(data: data)
        guard let obj = DiningHallParser().parse(xml)
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
        return DiningHallListParser().parse(xml)
    }
}
