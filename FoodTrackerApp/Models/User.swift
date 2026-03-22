//
//  User.swift
//  FoodTrackerApp
//
//  Created by Template
//

import Foundation

// MARK: - Gender
enum Gender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
}

// MARK: - User Model
struct User: Codable {
    var name: String
    var gender: Gender
    var weight: Double // в кг
    var height: Double // в см
    var age: Int
    var activityLevel: ActivityLevel
    
    // Таргеты для макросов (в граммах)
    var proteinTarget: Double // белки
    var carbsTarget: Double // углеводы
    var fatTarget: Double // жиры
    
    init(
        name: String = "",
        gender: Gender = .male,
        weight: Double = 70.0,
        height: Double = 170.0,
        age: Int = 30,
        activityLevel: ActivityLevel = .moderate,
        proteinTarget: Double = 0,
        carbsTarget: Double = 0,
        fatTarget: Double = 0
    ) {
        self.name = name
        self.gender = gender
        self.weight = weight
        self.height = height
        self.age = age
        self.activityLevel = activityLevel
        self.proteinTarget = proteinTarget
        self.carbsTarget = carbsTarget
        self.fatTarget = fatTarget
    }
    
    // Расчет базового метаболизма (BMR) по формуле Миффлина-Сан Жеора
    var bmr: Double {
        let base: Double
        if gender == .male {
            base = 10 * weight + 6.25 * height - 5 * Double(age) + 5
        } else {
            base = 10 * weight + 6.25 * height - 5 * Double(age) - 161
        }
        return base * activityLevel.multiplier
    }
    
    // Автоматический расчет таргетов на основе BMR (если не установлены вручную)
    var calculatedProteinTarget: Double {
        if proteinTarget > 0 {
            return proteinTarget
        }
        // Рекомендуется 1.6-2.2 г белка на кг веса
        return weight * 2.0
    }
    
    var calculatedCarbsTarget: Double {
        if carbsTarget > 0 {
            return carbsTarget
        }
        // Обычно 40-50% от калорий, 1г углеводов = 4 ккал
        return (bmr * 0.45) / 4.0
    }
    
    var calculatedFatTarget: Double {
        if fatTarget > 0 {
            return fatTarget
        }
        // Обычно 20-30% от калорий, 1г жиров = 9 ккал
        return (bmr * 0.25) / 9.0
    }
    
    var isProfileComplete: Bool {
        !name.isEmpty && weight > 0 && height > 0 && age > 0
    }
}

// MARK: - Activity Level
enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary = "Sedentary"
    case light = "Light"
    case moderate = "Moderate"
    case active = "Active"
    case veryActive = "Very Active"
    
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        case .veryActive: return 1.9
        }
    }
    
    var description: String {
        switch self {
        case .sedentary: return "Little or no exercise"
        case .light: return "Light exercise 1-3 days/week"
        case .moderate: return "Moderate exercise 3-5 days/week"
        case .active: return "Hard exercise 6-7 days/week"
        case .veryActive: return "Very hard exercise, physical job"
        }
    }
}

