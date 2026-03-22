//
//  NutritionAPIResponse.swift
//  FoodTrackerApp
//
//  Created by Template
//

import Foundation

// MARK: - BusyBody API Response Models
struct BusyBodySearchResponse: Codable {
    let results: [BusyBodyFood]?
    let data: [BusyBodyFood]?
    let foods: [BusyBodyFood]?
    let items: [BusyBodyFood]?
    
    // Универсальный геттер для получения массива продуктов
    var foodsArray: [BusyBodyFood] {
        return results ?? data ?? foods ?? items ?? []
    }
}

struct BusyBodyFood: Codable {
    let id: String?
    let foodId: String?
    let name: String?
    let label: String?
    let brand: String?
    let calories: Double?
    let protein: Double?
    let carbs: Double?
    let carbohydrates: Double?
    let fat: Double?
    let servingSize: String?
    let servingSizeGrams: Double?
    let image: String?
    let imageUrl: String?
    let nutrients: BusyBodyNutrients?
    
    // Универсальные геттеры для получения значений
    var foodName: String {
        return name ?? label ?? "Unknown"
    }
    
    var foodIdValue: String {
        return id ?? foodId ?? UUID().uuidString
    }
    
    var caloriesValue: Double {
        return calories ?? nutrients?.calories ?? 0
    }
    
    var proteinValue: Double {
        return protein ?? nutrients?.protein ?? 0
    }
    
    var carbsValue: Double {
        return carbs ?? carbohydrates ?? nutrients?.carbs ?? 0
    }
    
    var fatValue: Double {
        return fat ?? nutrients?.fat ?? 0
    }
    
    var servingSizeValue: String {
        return servingSize ?? "100g"
    }
    
    var imageUrlValue: String? {
        return image ?? imageUrl
    }
}

struct BusyBodyNutrients: Codable {
    let calories: Double?
    let energy: Double?
    let protein: Double?
    let carbs: Double?
    let carbohydrates: Double?
    let fat: Double?
    let fiber: Double?
    let sugar: Double?
    
    var caloriesValue: Double {
        return calories ?? energy ?? 0
    }
    
    var proteinValue: Double {
        return protein ?? 0
    }
    
    var carbsValue: Double {
        return carbs ?? carbohydrates ?? 0
    }
    
    var fatValue: Double {
        return fat ?? 0
    }
}

// MARK: - Legacy Edamam Support (для обратной совместимости)
struct NutritionAPIResponse: Codable {
    let foods: [NutritionFood]
}

struct NutritionFood: Codable {
    let foodId: String
    let label: String
    let brand: String?
    let nutrients: Nutrients
    let image: String?
    
    enum CodingKeys: String, CodingKey {
        case foodId
        case label
        case brand
        case nutrients
        case image
    }
}

struct Nutrients: Codable {
    let enercKcal: Double?
    let procnt: Double?
    let chocdf: Double?
    let fatValue: Double?
    
    enum CodingKeys: String, CodingKey {
        case enercKcal = "ENERC_KCAL"
        case procnt = "PROCNT"
        case chocdf = "CHOCDF"
        case fatValue = "FAT"
    }
    
    var calories: Double { enercKcal ?? 0 }
    var protein: Double { procnt ?? 0 }
    var carbs: Double { chocdf ?? 0 }
    var fat: Double { fatValue ?? 0 }
}

struct SearchResponse: Codable {
    let hints: [FoodHint]
}

struct FoodHint: Codable {
    let food: NutritionFood
}
