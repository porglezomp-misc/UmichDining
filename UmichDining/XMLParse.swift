//
//  XMLParse.swift
//  UmichDining
//
//  Created by Caleb Jones on 12/27/16.
//  Copyright © 2016 Caleb Jones. All rights reserved.
//

import Foundation
import Contacts


class DiningHallListParser: NSObject, XMLParserDelegate {
    private var childParser: DiningHallParser? = nil
    
    var halls: [DiningHall] = []
    
    /**
     Handles consuming the `XMLParser` events to produce a list of all known `DiningHall`s.
     
     - parameter parser: an `XMLParser` containing the XML of a dininghall index document.
     */
    func parse(_ parser: XMLParser) -> [DiningHall]? {
        halls = []
        parser.delegate = self
        parser.parse()
        return halls
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "dininghall" {
            childParser = DiningHallParser(parent: self)
            parser.delegate = childParser
        }
    }
}


class DiningHallParser: NSObject, XMLParserDelegate {
    weak var parentParser: DiningHallListParser?
    private var childParser: MenuParser? = nil
    
    var element: DiningHall? = nil
    var state: ParseState = .base
    var contact: CNMutableContact = CNMutableContact()
    var address : CNMutablePostalAddress = CNMutablePostalAddress()
    
    /**
     Parses a single `DiningHall`, to be used either on a single dininghall document, or delegated to from another parser.
     
     - parameter parser: an `XMLParser` containing a <dininghall> element.
     */
    func parse(_ parser: XMLParser) -> DiningHall? {
        parser.delegate = self
        parser.parse()
        return element
    }
    
    override init() {
        self.parentParser = nil
        super.init()
    }
    
    init(parent: DiningHallListParser) {
        self.parentParser = parent
        super.init()
    }
    
    enum ParseState {
        enum Address {
            case base
            case address1
            case address2
            case city
            case state
            case postalcode
        }
        
        enum Contact {
            case base
            case phone
            case email
        }
        
        case base
        case hours
        case type
        case name
        case contact(ParseState.Contact)
        case address(ParseState.Address)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
        case "menu":
            childParser = MenuParser(parent: self)
            parser.delegate = childParser
        case "hours":
            state = .hours
        case "address":
            state = .address(.base)
        case "address1":
            state = .address(.address1)
        case "address2":
            state = .address(.address2)
        case "city":
            state = .address(.city)
        case "state":
            state = .address(.state)
        case "postalcode":
            state = .address(.postalcode)
        case "type":
            state = .type
        case "name":
            state = .name
        case "contact":
            state = .contact(.base)
        case "phone":
            state = .contact(.phone)
        case "email":
            state = .contact(.email)
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        switch state {
        case .hours:
            let str = String(data: CDATABlock, encoding: .utf8) ?? ""
            contact.note += str + "\n"
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch state {
        case .name:
            contact.organizationName = string;
            element = DiningHall(string)
        case .address(.address1):
            address.street = string + "\n"
        case .address(.address2):
            address.street += string
        case .address(.city):
            address.city = string
        case .address(.state):
            address.state = string
        case .address(.postalcode):
            address.postalCode = string
        case .contact(.phone):
            contact.phoneNumbers = [CNLabeledValue(
                                        label: CNLabelPhoneNumberMain,
                                        value:CNPhoneNumber(stringValue: string))]
        case .contact(.email):
            contact.emailAddresses = [CNLabeledValue(label: CNLabelWork, value:string as NSString)]
        default: break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "dininghall":
            guard let element = element
                else { return }
            
            element.contact = contact
            
            if let parent = parentParser {
                parser.delegate = parent
                parent.halls.append(element)
            }
        case "address":
            address.isoCountryCode = "US"
            address.country = "United States"
            contact.postalAddresses = [CNLabeledValue(label:CNLabelWork, value:address)]
            state = .base
        case "hours", "type", "name", "contact":
            state = .base
        case "phone", "email":
            state = .contact(.base)
        case "address1", "address2", "city", "state", "postalcode":
            state = .address(.base)
        default: break
        }
    }
}

private class MenuParser: NSObject, XMLParserDelegate {
    weak var parentParser: DiningHallParser!
    private var childParser: MealParser? = nil
    
    var meals: [Meal] = []
    
    init(parent: DiningHallParser) {
        parentParser = parent
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "meal" {
            childParser = MealParser(parent: self)
            parser.delegate = childParser
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "menu" {
            parser.delegate = parentParser
            parentParser.element?.menu.meals = meals
        }
    }
}


private class MealParser: NSObject, XMLParserDelegate {
    weak var parentParser: MenuParser!
    private var childParser: CourseParser? = nil
    
    var name: String? = nil
    var courses: [String: [MenuItem]] = [:]
    var previousTag: String = ""
    
    init(parent: MenuParser) {
        self.parentParser = parent
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        previousTag = elementName
        if elementName == "course" {
            childParser = CourseParser(parent: self)
            parser.delegate = childParser
        }
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if previousTag == "name" {
            guard let name = String(data: CDATABlock, encoding: .utf8)
                else { return }
            self.name = name
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "meal" {
            parser.delegate = parentParser
            guard let name = name
                else { return }
            let notice: String?
            if let noticeItems = courses["notice"] {
                notice = noticeItems.first?.name
            } else {
                notice = nil
            }
            self.courses.removeValue(forKey: "notice")
            let meal = Meal(name: name, courses: courses)
            meal.notice = notice
            parentParser.meals.append(meal)
        }
    }
}


private class CourseParser: NSObject, XMLParserDelegate {
    weak var parentParser: MealParser!
    private var childParser: MenuItemParser? = nil
    
    var courseName: String? = nil
    var menuItems: [MenuItem] = []
    var state: ParseState = .base
    
    enum ParseState {
        case base
        case name
    }
    
    init(parent: MealParser) {
        self.parentParser = parent
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch state {
        case .base:
            switch elementName {
            case "name":
                state = .name
            case "menuitem":
                childParser = MenuItemParser(parent: self)
                parser.delegate = childParser
            default: break
            }
        case .name: break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if state == .name {
            courseName = string
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "name":
            state = .base
        case "course":
            parser.delegate = parentParser
            guard let courseName = courseName
                else { return }
            parentParser.courses[courseName] = menuItems
        default: break
        }
    }
}


private class MenuItemParser: NSObject, XMLParserDelegate {
    weak var parentParser: CourseParser!
    var item: MenuItem? = nil
    var previousTag: String = ""
    var handling: String = ""
    var nutrition: [String: Measurement<Unit>] = [:]
    var traits: [String] = []
    var allergens: [String] = []
    
    init(parent: CourseParser) {
        self.parentParser = parent
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        previousTag = elementName
        if ["nutrition", "allergens", "trait"].contains(elementName) {
            handling = elementName
        }
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if previousTag == "name" {
            guard let name = String(data: CDATABlock, encoding: .utf8)
                else { return }
            item = MenuItem(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
        }
        
        switch handling {
        case "trait":
            traits.append(string)
        case "allergens":
            allergens.append(string)
        case "nutrition":
            let value: Double?
            let unit: Unit
            if string.contains("gm") {
                value = Double(string.replacingOccurrences(of: "gm", with: ""))
                unit = UnitMass.grams
            } else if string.contains("mg") {
                value = Double(string.replacingOccurrences(of: "mg", with: ""))
                unit = UnitMass.milligrams
            } else if string.contains("mcg") {
                value = Double(string.replacingOccurrences(of: "mcg", with: ""))
                unit = UnitMass.micrograms
            } else if string.contains("iu") {
                // From http://www.viridian-nutrition.com/blog/nutrition-news-and-views/what-does-an-iu-measure-in-vitamins
                // The IU is an International Unit, usually used to measure fat soluble vitamins including Vitamin A, D and E.
                // The conversion of IU to mg varies depending on the nutrient.
                // VITAMIN A: One milligram of beta carotene = 1667IU of Vitamin A activity.
                // VITAMIN E: One milligram of Vitamin E = approx 1.21 to 1.49IU (depending on the carrier).
                // 400IU of d-alpha tocopherol = 268mg.
                // VITAMIN D: One microgram of Vitamin D = 40IU.
                switch previousTag {
                case "vtaiu":
                    value = Double(string.replacingOccurrences(of: "iu", with: ""))
                    unit = UnitMass(symbol: "iu", converter: UnitConverterLinear(coefficient: 0.000001 / 1667))
                default:
                    print(previousTag)
                    value = nil
                    unit = Unit()
                }
            } else if string.contains("kcal") {
                value = Double(string.replacingOccurrences(of: "kcal", with: ""))
                unit = UnitEnergy.kilocalories
            } else if previousTag.contains("_p") {
                value = Double(string)
                unit = Unit(symbol: "%")
            } else {
                value = Double(string)
                unit = Unit()
            }
            
            if let value = value {
                nutrition[previousTag] = Measurement(value: value, unit: unit)
            } else {
                print(string)
            }
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "menuitem":
            parser.delegate = parentParser
            guard let item = item
                else { return }
            item.nutritionInfo = nutrition
            item.allergens = allergens
            item.traits = traits
            parentParser.menuItems.append(item)
        case "nutrition", "allergens", "trait":
            handling = ""
        default: break
        }
    }
}
