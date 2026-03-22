//
//  FoodTrackerViewModel.swift
//  FoodTrackerApp
//
//  Created by Template
//

import Foundation
import SwiftUI
import Combine

@MainActor
class FoodTrackerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var entries: [FoodEntry] = []
    @Published var selectedDate = Date()
    @Published var showingAddFood = false
    @Published var showingProfile = false
    @Published var showingHistory = false
    @Published var isLoading = false
    @Published var user: User?
    
    // MARK: - Computed Properties
    var todayEntries: [FoodEntry] {
        entries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    var dailySummary: DailySummary {
        DailySummary(
            id: UUID(),
            date: selectedDate,
            entries: todayEntries
        )
    }
    
    var entriesByMeal: [MealType: [FoodEntry]] {
        Dictionary(grouping: todayEntries, by: { $0.mealType })
    }
    
    var weeklySummaries: [DailySummary] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        
        var summaries: [DailySummary] = []
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) {
                let dayEntries = entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
                summaries.append(DailySummary(id: UUID(), date: date, entries: dayEntries))
            }
        }
        return summaries
    }
    
    // MARK: - Initialization
    init() {
        loadData()
    }
    
    // MARK: - Public Methods
    func loadData() {
        entries = FoodStorage.shared.loadEntries()
        user = FoodStorage.shared.loadUser()
    }
    
    func addEntry(_ entry: FoodEntry) {
        entries.append(entry)
        saveEntries()
    }
    
    func deleteEntry(_ entry: FoodEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }
    
    func deleteEntry(at offsets: IndexSet, in mealType: MealType) {
        let mealEntries = entriesByMeal[mealType] ?? []
        for index in offsets {
            if let entry = mealEntries[safe: index] {
                deleteEntry(entry)
            }
        }
    }
    
    func saveEntries() {
        FoodStorage.shared.saveEntries(entries)
    }
    
    func saveUser(_ user: User) {
        self.user = user
        FoodStorage.shared.saveUser(user)
    }
    
    func changeDate(_ date: Date) {
        selectedDate = date
    }
    
    func goToToday() {
        selectedDate = Date()
    }
}

// MARK: - Array Extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

