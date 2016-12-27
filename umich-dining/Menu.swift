//
//  Menu.swift
//  umich-dining
//
//  Created by Caleb Jones on 12/26/16.
//  Copyright © 2016 Caleb Jones. All rights reserved.
//

import Foundation

class Menu {
    var meals: [Meal] = []
}

class Meal {
    var items: [MenuItem] = []
    var courses: [String: [MenuItem]] = [:]
    
    init(courses: [String: [MenuItem]]) {
        self.courses = courses
        self.items = courses.flatMap { $0.value }
    }
}

// TODO: Support multiple courses?
public class MenuItem {
    var name: String
    // TODO: Traits
    // TODO: Allergens
    // TODO: Serving size
    // TODO: What is portion size???
    var nutritionInfo: [String: Measurement] = [:]
    
    init(name: String) {
        self.name = name
    }
}
