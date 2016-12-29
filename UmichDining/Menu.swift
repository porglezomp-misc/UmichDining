//
//  Menu.swift
//  UmichDining
//
//  Created by Caleb Jones on 12/26/16.
//  Copyright © 2016 Caleb Jones. All rights reserved.
//

import Foundation


public func ==(lhs: Menu, rhs: Menu) -> Bool {
    return lhs.meals == rhs.meals
}

public class Menu: CustomDebugStringConvertible, Equatable {
    var meals: [Meal] = []
    
    public var debugDescription: String {
        return "Menu(meals: \(meals.debugDescription))"
    }
}

// I have no idea why this is necessary, but Swift doesn't seem to think that [T: [U]] is [T: V], so it can't compare two [T: [U]] to each other.
private func ==<T: Equatable, U: Equatable>(lhs: [T: [U]], rhs: [T: [U]]) -> Bool {
    if lhs.count != rhs.count { return false }
    for (idx, elem) in lhs {
        guard let other = rhs[idx]
            else { return false }
        if elem != other { return false }
    }
    return true
}

public func ==(lhs: Meal, rhs: Meal) -> Bool {
    return lhs.name == rhs.name && lhs.items == rhs.items && lhs.notice == rhs.notice && lhs.courses == rhs.courses
}

public class Meal: CustomDebugStringConvertible, Equatable {
    var name: String
    var items: [MenuItem] = []
    var courses: [String: [MenuItem]] = [:]
    var notice: String? = nil
    
    init(name: String, courses: [String: [MenuItem]]) {
        self.name = name
        self.courses = courses
        self.items = courses.flatMap { $0.value }
    }
    
    public var debugDescription: String {
        return "Meal(name: \(name.debugDescription), items: \(items.debugDescription), courses: \(courses.debugDescription), notice: \(notice.debugDescription))"
    }
}


public func ==(lhs: MenuItem, rhs: MenuItem) -> Bool {
    return lhs.name == rhs.name && lhs.traits == rhs.traits && lhs.allergens == rhs.allergens && lhs.nutritionInfo == rhs.nutritionInfo
}

public class MenuItem: CustomDebugStringConvertible, Equatable {
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
        return "MenuItem(name: \(name.debugDescription), traits: \(traits.debugDescription), allergens: \(allergens.debugDescription), nutritionInfo: \(nutritionInfo.debugDescription))"
    }
}
