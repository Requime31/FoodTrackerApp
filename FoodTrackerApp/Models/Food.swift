//
//  Food.swift
//  FoodTrackerApp
//
//  Created by Template
//

import Foundation
import SwiftUI

// MARK: - Food Model
struct Food: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var calories: Double // на 100г
    var protein: Double // на 100г
    var carbs: Double // на 100г
    var fat: Double // на 100г
    var servingSize: String // e.g., "100g", "1 cup"
    var brand: String?
    var imageUrl: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        calories: Double,
        protein: Double = 0,
        carbs: Double = 0,
        fat: Double = 0,
        servingSize: String = "100g",
        brand: String? = nil,
        imageUrl: String? = nil
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.servingSize = servingSize
        self.brand = brand
        self.imageUrl = imageUrl
    }
}

// MARK: - Meal Type
enum MealType: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    
    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .breakfast: return .orange
        case .lunch: return .yellow
        case .dinner: return .blue
        }
    }
}

// MARK: - Food Entry
struct FoodEntry: Identifiable, Codable {
    let id: UUID
    var food: Food
    var quantity: Double // в граммах
    var mealType: MealType
    var date: Date
    
    init(
        id: UUID = UUID(),
        food: Food,
        quantity: Double = 100.0,
        mealType: MealType = .breakfast,
        date: Date = Date()
    ) {
        self.id = id
        self.food = food
        self.quantity = quantity
        self.mealType = mealType
        self.date = date
    }
    
    // Расчет КБЖУ с учетом количества
    var totalCalories: Double {
        (food.calories / 100.0) * quantity
    }
    
    var totalProtein: Double {
        (food.protein / 100.0) * quantity
    }
    
    var totalCarbs: Double {
        (food.carbs / 100.0) * quantity
    }
    
    var totalFat: Double {
        (food.fat / 100.0) * quantity
    }
}

// MARK: - Daily Summary
struct DailySummary: Identifiable {
    let id: UUID
    let date: Date
    let entries: [FoodEntry]
    
    var totalCalories: Double {
        entries.reduce(0) { $0 + $1.totalCalories }
    }
    
    var totalProtein: Double {
        entries.reduce(0) { $0 + $1.totalProtein }
    }
    
    var totalCarbs: Double {
        entries.reduce(0) { $0 + $1.totalCarbs }
    }
    
    var totalFat: Double {
        entries.reduce(0) { $0 + $1.totalFat }
    }
    
    var entriesByMeal: [MealType: [FoodEntry]] {
        Dictionary(grouping: entries, by: { $0.mealType })
    }
    
    func caloriesForMeal(_ mealType: MealType) -> Double {
        entriesByMeal[mealType]?.reduce(0) { $0 + $1.totalCalories } ?? 0
    }
}

