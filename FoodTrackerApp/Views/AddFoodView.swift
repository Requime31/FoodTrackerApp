//
//  AddFoodView.swift
//  FoodTrackerApp
//
//  Created by Template
//

import SwiftUI

struct AddFoodView: View {
    @ObservedObject var viewModel: FoodTrackerViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    @State private var searchResults: [Food] = []
    @State private var isSearching = false
    @State private var selectedFood: Food?
    @State private var quantity = "100"
    @State private var selectedMealType: MealType = .breakfast
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar - фиксированная вверху
                searchBar
                    .background(Color(.systemBackground))
                
                // Контент с возможностью прокрутки
                ScrollView {
                    if isSearching {
                        ProgressView()
                            .padding()
                    } else if searchResults.isEmpty && !searchText.isEmpty {
                        Text("No results found")
                            .font(AppFonts.body)
                            .foregroundColor(.secondary)
                            .padding()
                    } else if let selected = selectedFood {
                        // Food Details Form
                        foodDetailsForm(food: selected)
                    } else {
                        // Search Results
                        searchResultsList
                    }
                }
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(AppFonts.body)
            
            TextField("Search food...", text: $searchText)
                .textFieldStyle(.plain)
                .font(AppFonts.body)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onSubmit {
                    performSearch()
                }
//                .onChange(of: searchText) { oldValue, newValue in
//                    if newValue.isEmpty {
//                        searchResults = []
//                        selectedFood = nil
//                        isSearching = false
//                    }
//                }
                .onChange(of: searchText) { newValue in
                        performReactiveSearch(query: newValue)
                }
                .onSubmit {
                    performSearch()
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    searchResults = []
                    selectedFood = nil
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(AppFonts.body)
                }
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(Color(.systemGray6))
        .cornerRadius(AppCornerRadius.medium)
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.sm)
    }
    
    // MARK: - Search Results List
    private var searchResultsList: some View {
        LazyVStack(spacing: 0) {
            ForEach(searchResults) { food in
                Button(action: {
                    selectedFood = food
                    quantity = "100"
                }) {
                    HStack(spacing: AppSpacing.md) {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text(food.name)
                                .font(AppFonts.headline)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            
                            if let brand = food.brand {
                                Text(brand)
                                    .font(AppFonts.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: AppSpacing.sm) {
                                Text("\(Int(food.calories)) kcal")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.calories)
                                Text("P:\(Int(food.protein)) C:\(Int(food.carbs)) F:\(Int(food.fat))")
                                    .font(AppFonts.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(AppFonts.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.md)
                    .background(Color(.systemBackground))
                }
                .buttonStyle(.plain)
                
                Divider()
                    .padding(.leading, AppSpacing.md)
            }
        }
    }
    
    // MARK: - Food Details Form
    private func foodDetailsForm(food: Food) -> some View {
        VStack(spacing: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text(food.name)
                    .font(AppFonts.title2)
                    .multilineTextAlignment(.leading)
                
                if let brand = food.brand {
                    Text(brand)
                        .font(AppFonts.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: AppSpacing.sm) {
                    macroBadge(label: "Cal", value: food.calories, color: AppColors.calories)
                    macroBadge(label: "P", value: food.protein, color: AppColors.protein)
                    macroBadge(label: "C", value: food.carbs, color: AppColors.carbs)
                    macroBadge(label: "F", value: food.fat, color: AppColors.fat)
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.md)
            
            VStack(spacing: AppSpacing.md) {
                HStack {
                    Text("Quantity")
                        .font(AppFonts.headline)
                    Spacer()
                    HStack {
                        TextField("100", text: $quantity)
                            .keyboardType(.decimalPad)
                            .font(AppFonts.body)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("grams")
                            .font(AppFonts.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(Color(.systemGray6))
                .cornerRadius(AppCornerRadius.medium)
                
                Picker("Meal Type", selection: $selectedMealType) {
                    ForEach(MealType.allCases, id: \.self) { mealType in
                        HStack {
                            Image(systemName: mealType.icon)
                            Text(mealType.rawValue)
                        }
                        .tag(mealType)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal, AppSpacing.md)
            }
            .padding(.horizontal, AppSpacing.md)
            
            Button(action: saveFood) {
                Text("Add Food")
                    .font(AppFonts.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(isValid ? AppColors.primary : Color.gray)
                    .cornerRadius(AppCornerRadius.medium)
            }
            .disabled(!isValid)
            .padding(.horizontal, AppSpacing.md)
            .padding(.bottom, AppSpacing.lg)
        }
    }
    
    private func macroBadge(label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(AppFonts.caption)
                .foregroundColor(.secondary)
            Text("\(Int(value))")
                .font(AppFonts.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.sm)
        .background(color.opacity(0.1))
        .cornerRadius(AppCornerRadius.small)
    }
    
    private var isValid: Bool {
        !quantity.isEmpty && Double(quantity) != nil && Double(quantity)! > 0
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        Task {
            do {
                let results = try await NutritionAPIManager.shared.searchFoods(query: searchText)
                await MainActor.run {
                    searchResults = results
                    isSearching = false
                    print("📊 Search completed. Found \(results.count) results")
                }
            } catch {
                await MainActor.run {
                    print("❌ Search error: \(error.localizedDescription)")
                    // Показываем примеры продуктов при ошибке
                    searchResults = getExampleFoods(query: searchText)
                    isSearching = false
                }
            }
        }
    }
    
    private func getExampleFoods(query: String) -> [Food] {
        let examples: [Food] = [
            Food(name: "Apple", calories: 52, protein: 0.3, carbs: 14, fat: 0.2, servingSize: "100g"),
            Food(name: "Banana", calories: 89, protein: 1.1, carbs: 23, fat: 0.3, servingSize: "100g"),
            Food(name: "Chicken Breast", calories: 165, protein: 31, carbs: 0, fat: 3.6, servingSize: "100g"),
            Food(name: "Chicken", calories: 165, protein: 31, carbs: 0, fat: 3.6, servingSize: "100g"),
            Food(name: "Grilled Chicken", calories: 165, protein: 31, carbs: 0, fat: 3.6, servingSize: "100g"),
            Food(name: "Rice", calories: 130, protein: 2.7, carbs: 28, fat: 0.3, servingSize: "100g"),
            Food(name: "Egg", calories: 155, protein: 13, carbs: 1.1, fat: 11, servingSize: "100g"),
            Food(name: "Bread", calories: 265, protein: 9, carbs: 49, fat: 3.2, servingSize: "100g"),
            Food(name: "Milk", calories: 42, protein: 3.4, carbs: 5, fat: 1, servingSize: "100ml"),
            Food(name: "Salmon", calories: 208, protein: 20, carbs: 0, fat: 12, servingSize: "100g"),
        ]
        
        let lowerQuery = query.lowercased()
        return examples.filter { $0.name.lowercased().contains(lowerQuery) || lowerQuery.isEmpty }
    }
    
    private func saveFood() {
        guard let food = selectedFood,
              let quantityValue = Double(quantity) else { return }
        
        let entry = FoodEntry(
            food: food,
            quantity: quantityValue,
            mealType: selectedMealType,
            date: viewModel.selectedDate
        )
        
        viewModel.addEntry(entry)
        dismiss()
    }
    
    private func performReactiveSearch(query: String) {
        isSearching = true
        Task {
            do {
                let results = try await NutritionAPIManager.shared.searchFoods(query: query)
                await MainActor.run {
                    self.searchResults = results
                    self.isSearching = false
                }
            } catch {
                await MainActor.run {
                    print("❌ Search error: \(error.localizedDescription)")
                    self.searchResults = getExampleFoods(query: query)
                    self.isSearching = false
                }
            }
        }
    }

}

#Preview {
    AddFoodView(viewModel: FoodTrackerViewModel())
}

