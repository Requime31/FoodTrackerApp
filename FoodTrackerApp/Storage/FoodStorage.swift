//
//  FoodStorage.swift
//  FoodTrackerApp
//
//  Created by Template
//

import Foundation
import Dispatch

// MARK: - Food Storage
class FoodStorage {
    static let shared = FoodStorage()
    
    private let userDefaults = UserDefaults.standard
    private let entriesKey = "food_entries"
    private let userKey = "user_profile"
    
    private init() {}
    
    // MARK: - Food Entries
    func saveEntries(_ entries: [FoodEntry]) {
        if let encoded = try? JSONEncoder().encode(entries) {
            userDefaults.set(encoded, forKey: entriesKey)
        }
    }
    
    func loadEntries() -> [FoodEntry] {
        guard let data = userDefaults.data(forKey: entriesKey),
              let decoded = try? JSONDecoder().decode([FoodEntry].self, from: data) else {
            return []
        }
        return decoded
    }
    
    func getEntries(for date: Date) -> [FoodEntry] {
        let allEntries = loadEntries()
        return allEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func getEntries(from startDate: Date, to endDate: Date) -> [FoodEntry] {
        let allEntries = loadEntries()
        return allEntries.filter { entry in
            entry.date >= startDate && entry.date <= endDate
        }
    }
    
    // MARK: - User Profile
    func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: userKey)
        }
    }
    
    func loadUser() -> User? {
        guard let data = userDefaults.data(forKey: userKey),
              let decoded = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return decoded
    }
    
    func clearAll() {
        userDefaults.removeObject(forKey: entriesKey)
        userDefaults.removeObject(forKey: userKey)
    }
    
    
}
    
