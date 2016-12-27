//
//  umich_diningTests.swift
//  umich-diningTests
//
//  Created by Caleb Jones on 12/26/16.
//  Copyright © 2016 Caleb Jones. All rights reserved.
//

import XCTest
@testable import umich_dining

class umich_diningTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let date = format.date(from: "2016-12-20")
        if let hall = bursley.blockingFetchData(date: date) {
            print("\(hall.menu.meals)")
            print("\(hall.contact)")
        } else {
            print("NONE!")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
