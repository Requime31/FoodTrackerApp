//
//  DesignSystem.swift
//  FoodTrackerApp
//
//  Created by Template
//

import SwiftUI

// MARK: - Цветовая палитра
struct AppColors {
    // Основные цвета
    static let primary = Color(red: 0.2, green: 0.6, blue: 0.9) // Мягкий синий
    static let secondary = Color(red: 0.3, green: 0.7, blue: 0.5) // Зеленый
    static let accent = Color(red: 1.0, green: 0.5, blue: 0.3) // Оранжевый
    
    // Фоновые цвета
    static let background = Color(red: 0.97, green: 0.97, blue: 0.98)
    static let surface = Color.white
    static let cardBackground = Color.white
    
    // Макронутриенты
    static let protein = Color(red: 0.2, green: 0.5, blue: 0.9) // Синий
    static let carbs = Color(red: 1.0, green: 0.6, blue: 0.2) // Оранжевый
    static let fat = Color(red: 0.9, green: 0.3, blue: 0.5) // Розовый
    static let calories = Color(red: 0.3, green: 0.7, blue: 0.5) // Зеленый
    
    // Градиенты
    static let primaryGradient = LinearGradient(
        colors: [Color(red: 0.2, green: 0.6, blue: 0.9), Color(red: 0.3, green: 0.7, blue: 0.5)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Типографика
struct AppFonts {
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title = Font.title.weight(.bold)
    static let title2 = Font.title2.weight(.semibold)
    static let title3 = Font.title3.weight(.semibold)
    static let headline = Font.headline
    static let body = Font.body
    static let callout = Font.callout
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption
    static let caption2 = Font.caption2
}

// MARK: - Радиусы скругления
struct AppCornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let extraLarge: CGFloat = 24
}

// MARK: - Spacing
struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

// MARK: - Анимации
struct AppAnimations {
    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.7)
    static let bouncy = Animation.spring(response: 0.3, dampingFraction: 0.5)
    static let smooth = Animation.easeInOut(duration: 0.3)
}

