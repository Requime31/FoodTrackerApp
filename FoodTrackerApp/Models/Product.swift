//
//  Product.swift
//  FoodTrackerApp
//
//  Created by Roman Shevchenko on 27/12/2025.
//

import Foundation

struct Product: Codable, Identifiable, Equatable {
    let name: String
    let calories: Float
    let protein: Float
    let fat: Float
    let carbs: Float
    let id: Int
    
    enum CodingKeys: String, CodingKey {
        case name, calories, protein, fat, carbs, id
    }
    
    // Преобразование Product в Food для использования в приложении
    func toFood() -> Food {
        Food(
            name: name,
            calories: Double(calories),
            protein: Double(protein),
            carbs: Double(carbs),
            fat: Double(fat),
            servingSize: "100g"
        )
    }
}
