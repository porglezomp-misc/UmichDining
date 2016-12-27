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
    let parentParser: DiningHallListParser?
    var element: DiningHall? = nil
    
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
