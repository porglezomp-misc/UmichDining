//
//  DiningHall.swift
//  umich-dining
//
//  Created by Caleb Jones on 12/26/16.
//  Copyright © 2016 Caleb Jones. All rights reserved.
//

import Foundation
import CoreLocation

let Barbour = DiningHall("Barbour", id: "barbour dining hall")
let Bursley = DiningHall("Bursley", id: "bursley dining hall")
let EastQuad = DiningHall("East Quad", id: "east quad dining hall")
let MosherJordan = DiningHall("Mosher-Jordan", id: "mosher jordan dining hall")
let Markley = DiningHall("Markley", id: "markley dining hall")
let NorthQuad = DiningHall("North Quad", id: "north quad dining hall")
let SouthQuad = DiningHall("South Quad", id: "south quad dining hall")
let Twigs = DiningHall("Twigs", id: "twigs at oxford")
let WestQuad = DiningHall("West Quad", id: "west quad dining hall")

private let baseUrl: URL = URL(string: "www.housing.umich.edu/files/helper_files/js/menu2xml.php")!

class DiningHall {
    let name: String
    let id: String
    var menu: Menu? = nil
    
    // TODO: Addresses / lat-lon
    
    init?(_ name: String, id: String) {
        self.name = name
        guard let id = id.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            else { return nil }
        self.id = id
    }

    func fetchMenu(date: Date? = nil, completion: @escaping (DiningHall) -> ()) {
        let queue = DispatchQueue(label: "net.calebjones.fetch-menu")
        queue.async {
            completion(self.blockingFetchMenu())
        }
    }
    
    func blockingFetchMenu(date: Date? = nil) -> DiningHall {
        // TODO: Unimplemented
        assert(false)
        return self
    }
    
    static func fetchDiningHalls(completion: @escaping ([DiningHall]) -> ()) {
        let queue = DispatchQueue(label: "net.calebjones.fetch-dining-halls")
        queue.async {
            completion(self.blockingFetchDiningHalls())
        }
    }
    
    static func blockingFetchDiningHalls() -> [DiningHall] {
        // TODO: Do this actually
        assert(false)
    }
}
