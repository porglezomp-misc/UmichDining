//
//  UmichDiningTests.swift
//  UmichDiningTests
//
//  Created by Caleb Jones on 12/26/16.
//  Copyright © 2016 Caleb Jones. All rights reserved.
//

import XCTest
import Contacts
@testable import UmichDining


class umich_diningTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParseSingleMealHall() {
        let file = Bundle(for: type(of: self)).path(forResource: "SingleMeal", ofType: "xml")!
        let xml = XMLParser(data: try! String(contentsOfFile: file).data(using: .utf8)!)
        let diningHall = DiningHallParser().parse(xml)!
        let twigs = DiningHall("Twigs at Oxford")
        let menu = Menu()
        let cereal = MenuItem(name: "Blueberry Oatmeal")
        cereal.traits = ["vegetarian"]
        cereal.allergens = ["milk", "oats"]
        cereal.nutritionInfo = [
            "fat": Measurement(value: 12, unit: UnitMass.grams),
            "kj": Measurement(value: 111, unit: Unit(symbol: "")),
            "kcal": Measurement(value: 285, unit: UnitEnergy.kilocalories),
            "b12": Measurement(value: 0, unit: UnitMass.micrograms),
            "vtaiu": Measurement(value: 390, unit: UnitMass(symbol: "iu", converter: UnitConverterLinear(coefficient: 0.000001 / 1667))),
            "sugar": Measurement(value: 15, unit: UnitMass.grams),
            "na": Measurement(value: 66, unit: UnitMass.milligrams),
            "cho_p": Measurement(value: 13, unit: Unit(symbol: "%")),
            "kcal_p": Measurement(value: 14, unit: Unit(symbol: "%")),
            "sugar_p": Measurement(value: 30, unit: Unit(symbol: "%")),
        ]
        menu.meals = [Meal(name: "BREAKFAST", courses: [
            "Hot Cereal": [
                cereal
            ]])]
        twigs.menu = menu
        XCTAssertEqual(diningHall, twigs)
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let date = format.date(from: "2016-12-20")
        if let hall = DiningHalls.bursley.blockingFetchData(date: date) {
            debugPrint(hall)
        } else {
            print("NONE!")
        }
        
        if let halls = DiningHall.blockingFetchDiningHalls(){
            print ("number of dining halls: \(halls.count)")
            var st = ""
            for hall in halls{
                 st += hall.name + "\n"
            }
            print(st)
            
        }
    }
    
}
