//
//  Menu.swift
//  umich-dining
//
//  Created by Caleb Jones on 12/26/16.
//  Copyright © 2016 Caleb Jones. All rights reserved.
//

import Foundation

class Menu: CustomDebugStringConvertible {
    var meals: [Meal] = []
    
    public var debugDescription: String {
        return "Menu(meals: \(meals.debugDescription))"
    }
}

class Meal: CustomDebugStringConvertible {
    var name: String
    var items: [MenuItem] = []
    var courses: [String: [MenuItem]] = [:]
    
    init(name: String, courses: [String: [MenuItem]]) {
        self.name = name
        self.courses = courses
        self.items = courses.flatMap { $0.value }
    }
    
    public var debugDescription: String {
        return "Meal(name: \(name), items: \(items.debugDescription), courses: \(courses.debugDescription))"
    }
}

// TODO: Support multiple courses?
public class MenuItem: CustomDebugStringConvertible {
    var name: String
    var traits: [String] = []
    var allergens: [String] = []
    // TODO: Serving size
    // TODO: What is portion size???
    var nutritionInfo: [String: Measurement] = [:]
    
    init(name: String) {
        self.name = name
    }
    
    public var debugDescription: String {
        return "MenuItem(name: \(name), traits: \(traits.debugDescription), allergens: \(allergens.debugDescription), nutritionInfo: \(nutritionInfo.debugDescription))"
    }
}
