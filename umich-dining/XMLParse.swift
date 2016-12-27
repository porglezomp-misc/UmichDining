//
//  XMLParse.swift
//  umich-dining
//
//  Created by Caleb Jones on 12/27/16.
//  Copyright © 2016 Caleb Jones. All rights reserved.
//

import Foundation
import Contacts

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
    var state: ParseState = .base
    var contact: CNMutableContact = CNMutableContact()
    var address : CNMutablePostalAddress = CNMutablePostalAddress()
    
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
    
    override init() {
        self.parentParser = nil
        super.init()
    }
    
    init(parent: DiningHallListParser) {
        self.parentParser = parent
        super.init()
    }
    
    func parse(parser: XMLParser) -> DiningHall? {
        parser.delegate = self
        parser.parse()
    
        return element
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        switch elementName {
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
        default:
            print(elementName)
        }
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        switch state {
        case .hours:
            let str = String(data: CDATABlock, encoding: .utf8) ?? ""
            contact.note += str + "\n"
        default:
            print(String(data: CDATABlock, encoding: .utf8) ?? "")
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
        default:
            print(string)
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
            contact.postalAddresses = [CNLabeledValue(label:CNLabelWork, value:address)]
            state = .base
        case "hours", "type", "name", "contact":
            state = .base
        case "phone", "email":
            state = .contact(.base)
        case "address1", "address2", "city", "state", "postalcode":
            state = .address(.base)
        default:
            print(elementName)
        }
    }
}
