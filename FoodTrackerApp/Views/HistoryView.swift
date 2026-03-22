//
//  HistoryView.swift
//  FoodTrackerApp
//
//  Created by Template
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: FoodTrackerViewModel
    @State private var selectedDate: Date = Date()
    @State private var selectedDaySummary: DailySummary?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Month Navigation
                monthNavigation
                
                // Calendar Grid
                calendarGrid
            }
            .background(AppColors.background)
            .navigationTitle("History")
            .sheet(isPresented: Binding(
                get: { selectedDaySummary != nil },
                set: { if !$0 { selectedDaySummary = nil } }
            )) {
                if let summary = selectedDaySummary {
                    DayDetailSheet(summary: summary)
                }
            }
        }
    }
    
    // MARK: - Month Navigation
    private var monthNavigation: some View {
        HStack {
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    if let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) {
                        selectedDate = previousMonth
                    }
                }
            }) {
                Image(systemName: "chevron.left.circle.fill")
                    .foregroundColor(AppColors.primary)
                    .font(.title2)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(monthYearString)
                    .font(AppFonts.title2)
                    .foregroundColor(.primary)
                
                Text("\(daysWithDataCount) days with data")
                    .font(AppFonts.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) {
                        selectedDate = nextMonth
                    }
                }
            }) {
                Image(systemName: "chevron.right.circle.fill")
                    .foregroundColor(AppColors.primary)
                    .font(.title2)
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.md)
        .background(AppColors.surface)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private var daysWithDataCount: Int {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 30
        
        var count = 0
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                let dayEntries = viewModel.entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
                if !dayEntries.isEmpty {
                    count += 1
                }
            }
        }
        return count
    }
    
    // MARK: - Calendar Grid
    private var calendarGrid: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                // Weekday Headers
                weekdayHeaders
                
                // Calendar Days
                calendarDays
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.md)
        }
    }
    
    private var weekdayHeaders: some View {
        HStack(spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { day in
                Text(day)
                    .font(AppFonts.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, AppSpacing.sm)
    }
    
    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols
    }
    
    private var calendarDays: some View {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 30
        let leadingPadding = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
            // Empty cells for days before month starts
            ForEach(0..<leadingPadding, id: \.self) { _ in
                Color.clear
                    .frame(height: 60)
            }
            
            // Days of the month
            ForEach(1...daysInMonth, id: \.self) { day in
                if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                    calendarDayCell(date: date, day: day)
                }
            }
        }
    }
    
    private func calendarDayCell(date: Date, day: Int) -> some View {
        let calendar = Calendar.current
        let dayEntries = viewModel.entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
        let hasData = !dayEntries.isEmpty
        let isToday = calendar.isDateInToday(date)
        let isSelectedMonth = calendar.isDate(date, equalTo: selectedDate, toGranularity: .month)
        
        let summary = DailySummary(id: UUID(), date: date, entries: dayEntries)
        let calories = summary.totalCalories
        let userBMR = viewModel.user?.bmr ?? 2000
        let progress = min(calories / userBMR, 1.0)
        
        return Button(action: {
            if hasData {
                print("📅 Selected date: \(date), entries: \(dayEntries.count)")
                selectedDaySummary = summary
            }
        }) {
            VStack(spacing: 4) {
                Text("\(day)")
                    .font(isToday ? AppFonts.headline : AppFonts.body)
                    .foregroundColor(isToday ? AppColors.primary : (isSelectedMonth ? .primary : .secondary))
                
                if hasData {
                    ZStack {
                        Circle()
                            .fill(AppColors.calories.opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                AppColors.calories,
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 32, height: 32)
                        
                        Text("\(Int(calories))")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(AppColors.calories)
                    }
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 32, height: 32)
                }
            }
            .frame(width: 50, height: 60)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.small)
                    .fill(isToday ? AppColors.primary.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .disabled(!hasData)
    }
}

// MARK: - Day Detail Sheet
struct DayDetailSheet: View {
    let summary: DailySummary
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Date Header
                    dateHeader
                    
                    // Summary Card
                    summaryCard
                    
                    // Meals Breakdown
                    mealsBreakdown
                }
                .padding(AppSpacing.md)
            }
            .background(AppColors.background)
            .navigationTitle("Daily Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.primary)
                }
            }
        }
        .onAppear {
            print("📊 DayDetailSheet appeared with \(summary.entries.count) entries")
            print("📊 Total calories: \(summary.totalCalories)")
        }
    }
    
    private var dateHeader: some View {
        VStack(spacing: AppSpacing.xs) {
            Text(summary.date, style: .date)
                .font(AppFonts.title2)
            
            if Calendar.current.isDateInToday(summary.date) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                    Text("Today")
                        .font(AppFonts.caption)
                }
                .foregroundColor(AppColors.primary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
    }
    
    private var summaryCard: some View {
        VStack(spacing: AppSpacing.md) {
            // Calories
            VStack(spacing: AppSpacing.xs) {
                Text("\(Int(summary.totalCalories))")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(AppColors.calories)
                Text("kcal")
                    .font(AppFonts.headline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, AppSpacing.md)
            
            Divider()
            
            // Macros
            VStack(spacing: AppSpacing.md) {
                macroRow(label: "Protein", value: summary.totalProtein, color: AppColors.protein, icon: "leaf.fill")
                macroRow(label: "Carbs", value: summary.totalCarbs, color: AppColors.carbs, icon: "flame.fill")
                macroRow(label: "Fat", value: summary.totalFat, color: AppColors.fat, icon: "drop.fill")
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.surface)
        .cornerRadius(AppCornerRadius.large)
        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
    }
    
    private func macroRow(label: String, value: Double, color: Color, icon: String) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(label)
                .font(AppFonts.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(Int(value))g")
                .font(AppFonts.title3)
                .foregroundColor(color)
        }
        .padding(.vertical, AppSpacing.sm)
        .padding(.horizontal, AppSpacing.md)
        .background(color.opacity(0.1))
        .cornerRadius(AppCornerRadius.medium)
    }
    
    private var mealsBreakdown: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Meals Breakdown")
                .font(AppFonts.title2)
            
            ForEach(MealType.allCases, id: \.self) { mealType in
                mealBreakdownCard(mealType: mealType)
            }
        }
    }
    
    private func mealBreakdownCard(mealType: MealType) -> some View {
        let mealEntries = summary.entriesByMeal[mealType] ?? []
        let mealCalories = mealEntries.reduce(0) { $0 + $1.totalCalories }
        
        return VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Image(systemName: mealType.icon)
                    .font(.title3)
                    .foregroundColor(mealType.color)
                    .frame(width: 30)
                
                Text(mealType.rawValue)
                    .font(AppFonts.headline)
                
                Spacer()
                
                Text("\(Int(mealCalories)) kcal")
                    .font(AppFonts.headline)
                    .foregroundColor(mealType.color)
            }
            
            if !mealEntries.isEmpty {
                VStack(spacing: AppSpacing.xs) {
                    ForEach(mealEntries) { entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.food.name)
                                    .font(AppFonts.body)
                                Text("\(String(format: "%.0f", entry.quantity))g")
                                    .font(AppFonts.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("\(Int(entry.totalCalories)) kcal")
                                .font(AppFonts.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, AppSpacing.xs)
                    }
                }
                .padding(.top, AppSpacing.xs)
            } else {
                Text("No items")
                    .font(AppFonts.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, AppSpacing.xs)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .cornerRadius(AppCornerRadius.medium)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    HistoryView(viewModel: FoodTrackerViewModel())
}
