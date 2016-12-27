//
//  XMLParse.swift
//  umich-dining
//
//  Created by Caleb Jones on 12/27/16.
//  Copyright © 2016 Caleb Jones. All rights reserved.
//

import Foundation

class DiningHallListParser: NSObject, XMLParserDelegate {
    var halls: [DiningHall] = []
    
    func parse(parser: XMLParser) -> [DiningHall] {
        halls = []
        parser.delegate = self
        parser.parse()
        return halls
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "dininghall" {
            parser.delegate = DiningHallParser(parent: self)
        }
    }
}

class DiningHallParser: NSObject, XMLParserDelegate {
    weak var parentParser: DiningHallListParser?
    var element: DiningHall? = nil
    private var childParser: MenuParser? = nil
    
    override init() {
        self.parentParser = nil
        super.init()
    }
    
    init(parent: DiningHallListParser) {
        self.parentParser = parent
        super.init()
    }
    
    func parse(parser: XMLParser) -> DiningHall? {
        element = nil
        parser.delegate = self
        parser.parse()
        return element
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "menu" {
            childParser = MenuParser(parent: self)
            parser.delegate = childParser
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "dininghall" {
            guard let element = element
                else { return }
            
            if let parent = parentParser {
                parser.delegate = parent
                parent.halls.append(element)
            }
        }
    }
}

private class MenuParser: NSObject, XMLParserDelegate {
    weak var parentParser: DiningHallParser!
    var meals: [Meal] = []
    private var childParser: MealParser? = nil
    
    init(parent: DiningHallParser) {
        self.parentParser = parent
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
            parentParser.element?.menu?.meals = meals
        }
    }
}

private class MealParser: NSObject, XMLParserDelegate {
    weak var parentParser: MenuParser!
    var courses: [String: [MenuItem]] = [:]
    private var childParser: CourseParser? = nil
    
    init(parent: MenuParser) {
        self.parentParser = parent
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "course" {
            childParser = CourseParser(parent: self)
            parser.delegate = childParser
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "meal" {
            parser.delegate = parentParser
            parentParser.meals.append(Meal(courses: courses))
        }
    }
}

private class CourseParser: NSObject, XMLParserDelegate {
    weak var parentParser: MealParser!
    var courseName: String? = nil
    var menuItems: [MenuItem] = []
    var state: ParseState = .base
    private var childParser: MenuItemParser? = nil
    
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
            if elementName == "name" {
                state = .name
            } else if elementName == "menuitem" {
                childParser = MenuItemParser(parent: self)
                parser.delegate = childParser
            } else {
                print(elementName)
            }
        case .name:
            print(elementName)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print(string)
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
    
    init(parent: CourseParser) {
        self.parentParser = parent
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "menuitem" {
            parser.delegate = parentParser
            guard let item = item
                else { return }
            parentParser.menuItems.append(item)
        }
    }
}
