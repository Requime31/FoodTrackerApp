//
//  FoodTrackerView.swift
//  FoodTrackerApp
//
//  Created by Template
//

import SwiftUI

struct FoodTrackerView: View {
    @ObservedObject var viewModel: FoodTrackerViewModel
    @State private var showingDatePicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Date Selector
                    dateSelector
                    
                    // Daily Summary Card
                    dailySummaryCard
                    
                    // Meals List
                    mealsList
                }
                .padding(AppSpacing.md)
            }
            .background(AppColors.background)
            .navigationTitle("Food Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showingAddFood = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddFood) {
                AddFoodView(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Date Selector
    private var dateSelector: some View {
        HStack {
            Button(action: {
                if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: viewModel.selectedDate) {
                    viewModel.changeDate(previousDay)
                }
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(AppColors.primary)
            }
            
            Spacer()
            
            Button(action: {
                showingDatePicker = true
            }) {
                VStack(spacing: AppSpacing.xs) {
                    Text(viewModel.selectedDate, style: .date)
                        .font(AppFonts.headline)
                        .foregroundColor(.primary)
                    
                    if Calendar.current.isDateInToday(viewModel.selectedDate) {
                        Text("Today")
                            .font(AppFonts.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text(dayName(for: viewModel.selectedDate))
                            .font(AppFonts.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: viewModel.selectedDate) {
                    viewModel.changeDate(nextDay)
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.primary)
            }
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(AppCornerRadius.medium)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingDatePicker) {
            DatePicker(
                "Select Date",
                selection: Binding(
                    get: { viewModel.selectedDate },
                    set: { viewModel.changeDate($0) }
                ),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .presentationDetents([.medium])
        }
    }
    
    // MARK: - Daily Summary Card
    private var dailySummaryCard: some View {
        let summary = viewModel.dailySummary
        let userBMR = viewModel.user?.bmr ?? 2000
        
        return VStack(spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Daily Summary")
                        .font(AppFonts.title2)
                    if let user = viewModel.user {
                        Text("Goal: \(Int(user.bmr)) kcal")
                            .font(AppFonts.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                    Text("\(Int(summary.totalCalories))")
                        .font(AppFonts.title)
                        .foregroundColor(AppColors.calories)
                    Text("kcal")
                        .font(AppFonts.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress Bar
            if userBMR > 0 {
                ProgressView(value: min(summary.totalCalories / userBMR, 1.0))
                    .tint(AppColors.calories)
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            
            // Macros with Circular Progress
            if let user = viewModel.user {
                HStack(spacing: AppSpacing.md) {
                    MacroProgressCard(
                        label: "Protein",
                        current: summary.totalProtein,
                        target: user.calculatedProteinTarget,
                        color: AppColors.protein,
                        unit: "g"
                    )
                    
                    MacroProgressCard(
                        label: "Carbs",
                        current: summary.totalCarbs,
                        target: user.calculatedCarbsTarget,
                        color: AppColors.carbs,
                        unit: "g"
                    )
                    
                    MacroProgressCard(
                        label: "Fat",
                        current: summary.totalFat,
                        target: user.calculatedFatTarget,
                        color: AppColors.fat,
                        unit: "g"
                    )
                }
            } else {
                // Fallback if no user profile
                HStack(spacing: AppSpacing.sm) {
                    macroItem(
                        label: "Protein",
                        value: summary.totalProtein,
                        color: AppColors.protein
                    )
                    
                    macroItem(
                        label: "Carbs",
                        value: summary.totalCarbs,
                        color: AppColors.carbs
                    )
                    
                    macroItem(
                        label: "Fat",
                        value: summary.totalFat,
                        color: AppColors.fat
                    )
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .cornerRadius(AppCornerRadius.large)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private func macroItem(label: String, value: Double, color: Color) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Text(label)
                .font(AppFonts.caption)
                .foregroundColor(.secondary)
            Text("\(Int(value))g")
                .font(AppFonts.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.sm)
        .background(color.opacity(0.1))
        .cornerRadius(AppCornerRadius.small)
    }
    
    // MARK: - Meals List
    private var mealsList: some View {
        VStack(spacing: AppSpacing.md) {
            ForEach(MealType.allCases, id: \.self) { mealType in
                mealSection(mealType: mealType)
            }
        }
    }
    
    private func mealSection(mealType: MealType) -> some View {
        let mealEntries = viewModel.entriesByMeal[mealType] ?? []
        let mealCalories = mealEntries.reduce(0) { $0 + $1.totalCalories }
        
        return VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: mealType.icon)
                    .font(.title3)
                    .foregroundColor(mealType.color)
                    .frame(width: 24, height: 24)
                
                Text(mealType.rawValue)
                    .font(AppFonts.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(Int(mealCalories))")
                    .font(AppFonts.title3)
                    .fontWeight(.bold)
                    .foregroundColor(mealType.color)
                
                Text("kcal")
                    .font(AppFonts.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(mealType.color.opacity(0.1))
            
            Divider()
            
            // Content
            if mealEntries.isEmpty {
                HStack {
                    Spacer()
                    Text("No items yet")
                        .font(AppFonts.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, AppSpacing.lg)
                    Spacer()
                }
            } else {
                VStack(spacing: 0) {
                    ForEach(mealEntries) { entry in
                        FoodEntryRow(entry: entry) {
                            viewModel.deleteEntry(entry)
                        }
                        
                        if entry.id != mealEntries.last?.id {
                            Divider()
                                .padding(.leading, AppSpacing.md)
                        }
                    }
                }
            }
        }
        .background(AppColors.surface)
        .cornerRadius(AppCornerRadius.medium)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func dayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}

// MARK: - Food Entry Row
struct FoodEntryRow: View {
    let entry: FoodEntry
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(entry.food.name)
                    .font(AppFonts.headline)
                    .foregroundColor(.primary)
                
                Text("\(String(format: "%.0f", entry.quantity))g")
                    .font(AppFonts.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                Text("\(Int(entry.totalCalories))")
                    .font(AppFonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.calories)
                
                Text("kcal")
                    .font(AppFonts.caption2)
                    .foregroundColor(.secondary)
                
                HStack(spacing: AppSpacing.xs) {
                    Text("P:\(Int(entry.totalProtein))")
                        .font(AppFonts.caption2)
                        .foregroundColor(AppColors.protein)
                    Text("C:\(Int(entry.totalCarbs))")
                        .font(AppFonts.caption2)
                        .foregroundColor(AppColors.carbs)
                    Text("F:\(Int(entry.totalFat))")
                        .font(AppFonts.caption2)
                        .foregroundColor(AppColors.fat)
                }
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.red.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .contentShape(Rectangle())
    }
}

#Preview {
    FoodTrackerView(viewModel: FoodTrackerViewModel())
}

