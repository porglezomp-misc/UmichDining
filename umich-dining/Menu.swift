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
    var items: [MenuItem] = []
    var courses: [String: [MenuItem]] = [:]
    
    init(courses: [String: [MenuItem]]) {
        self.courses = courses
        self.items = courses.flatMap { $0.value }
    }
    
    public var debugDescription: String {
        return "Meal(items: \(items.debugDescription), courses: \(courses.debugDescription))"
    }
}

// TODO: Support multiple courses?
public class MenuItem: CustomDebugStringConvertible {
    var name: String
    // TODO: Traits
    // TODO: Allergens
    // TODO: Serving size
    // TODO: What is portion size???
    var nutritionInfo: [String: Measurement] = [:]
    
    init(name: String) {
        self.name = name
    }
    
    public var debugDescription: String {
        return "MenuItem(name: \(name), nutritionInfo: \(nutritionInfo.debugDescription))"
    }
}
