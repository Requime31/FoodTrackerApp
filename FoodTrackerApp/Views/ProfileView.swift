//
//  ProfileView.swift
//  FoodTrackerApp
//
//  Created by Template
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: FoodTrackerViewModel
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Profile Header
                    profileHeader
                    
                    // Daily Goal Card
                    dailyGoalCard
                    
                    // Personal Info Card
                    personalInfoCard
                    
                    // Activity Level Card
                    activityLevelCard
                    
                    // Macro Targets Card
                    macroTargetsCard
                }
                .padding(AppSpacing.md)
            }
            .background(AppColors.background)
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingEditProfile = true
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(viewModel: viewModel, isPresented: $showingEditProfile)
            }
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryGradient)
                    .frame(width: 100, height: 100)
                
                Text(profileInitials)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(viewModel.user?.name.isEmpty == false ? viewModel.user!.name : "No Name")
                .font(AppFonts.title2)
            
            if let user = viewModel.user, user.isProfileComplete {
                Text("\(Int(user.bmr)) kcal daily goal")
                    .font(AppFonts.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Complete your profile")
                    .font(AppFonts.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
    }
    
    private var profileInitials: String {
        guard let name = viewModel.user?.name, !name.isEmpty else {
            return "?"
        }
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
    
    // MARK: - Daily Goal Card
    private var dailyGoalCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Daily Calorie Goal")
                .font(AppFonts.title2)
            
            if let user = viewModel.user, user.isProfileComplete {
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("BMR")
                            .font(AppFonts.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(user.bmr))")
                            .font(AppFonts.title)
                            .foregroundColor(AppColors.calories)
                    }
                    
                    Spacer()
                    
                    Text("kcal")
                        .font(AppFonts.headline)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Set up your profile to see your daily calorie goal")
                    .font(AppFonts.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface)
        .cornerRadius(AppCornerRadius.large)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Personal Info Card
    private var personalInfoCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Personal Information")
                .font(AppFonts.title2)
            
            if let user = viewModel.user {
                infoRow(label: "Name", value: user.name.isEmpty ? "Not set" : user.name)
                infoRow(label: "Gender", value: user.gender.rawValue)
                infoRow(label: "Weight", value: "\(String(format: "%.1f", user.weight)) kg")
                infoRow(label: "Height", value: "\(String(format: "%.0f", user.height)) cm")
                infoRow(label: "Age", value: "\(user.age) years")
            } else {
                Text("No profile data")
                    .font(AppFonts.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface)
        .cornerRadius(AppCornerRadius.large)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(AppFonts.body)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(AppFonts.headline)
        }
        .padding(.vertical, AppSpacing.xs)
    }
    
    // MARK: - Activity Level Card
    private var activityLevelCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Activity Level")
                .font(AppFonts.title2)
            
            if let user = viewModel.user {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(user.activityLevel.rawValue)
                        .font(AppFonts.headline)
                    Text(user.activityLevel.description)
                        .font(AppFonts.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Not set")
                    .font(AppFonts.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface)
        .cornerRadius(AppCornerRadius.large)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Macro Targets Card
    private var macroTargetsCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Macro Targets")
                .font(AppFonts.title2)
            
            if let user = viewModel.user, user.isProfileComplete {
                HStack(spacing: AppSpacing.md) {
                    macroTargetItem(
                        label: "Protein",
                        target: user.calculatedProteinTarget,
                        color: AppColors.protein
                    )
                    
                    macroTargetItem(
                        label: "Carbs",
                        target: user.calculatedCarbsTarget,
                        color: AppColors.carbs
                    )
                    
                    macroTargetItem(
                        label: "Fat",
                        target: user.calculatedFatTarget,
                        color: AppColors.fat
                    )
                }
                
                Text("Edit profile to customize targets")
                    .font(AppFonts.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Complete your profile to see macro targets")
                    .font(AppFonts.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface)
        .cornerRadius(AppCornerRadius.large)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private func macroTargetItem(label: String, target: Double, color: Color) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Text(label)
                .font(AppFonts.caption)
                .foregroundColor(.secondary)
            Text("\(Int(target))g")
                .font(AppFonts.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.sm)
        .background(color.opacity(0.1))
        .cornerRadius(AppCornerRadius.small)
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @ObservedObject var viewModel: FoodTrackerViewModel
    @Binding var isPresented: Bool
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var gender: Gender = .male
    @State private var weight = ""
    @State private var height = ""
    @State private var age = ""
    @State private var activityLevel: ActivityLevel = .moderate
    @State private var proteinTarget = ""
    @State private var carbsTarget = ""
    @State private var fatTarget = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    TextField("Name", text: $name)
                        .font(AppFonts.body)
                    
                    Picker("Gender", selection: $gender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .font(AppFonts.body)
                    
                    HStack {
                        TextField("Weight", text: $weight)
                            .keyboardType(.decimalPad)
                            .font(AppFonts.body)
                        Text("kg")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        TextField("Height", text: $height)
                            .keyboardType(.decimalPad)
                            .font(AppFonts.body)
                        Text("cm")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        TextField("Age", text: $age)
                            .keyboardType(.numberPad)
                            .font(AppFonts.body)
                        Text("years")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Activity Level") {
                    Picker("Activity", selection: $activityLevel) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            VStack(alignment: .leading) {
                                Text(level.rawValue)
                                    .font(AppFonts.body)
                                Text(level.description)
                                    .font(AppFonts.caption)
                                    .foregroundColor(.secondary)
                            }
                            .tag(level)
                        }
                    }
                }
                
                Section("Daily Calorie Goal") {
                    if let bmr = calculatedBMR {
                        HStack {
                            Text("BMR")
                                .font(AppFonts.headline)
                            Spacer()
                            Text("\(Int(bmr)) kcal")
                                .font(AppFonts.title2)
                                .foregroundColor(AppColors.calories)
                        }
                    }
                }
                
                Section("Macro Targets (grams)") {
                    HStack {
                        Text("Protein")
                            .font(AppFonts.body)
                        Spacer()
                        TextField("Auto", text: $proteinTarget)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(AppFonts.body)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Carbs")
                            .font(AppFonts.body)
                        Spacer()
                        TextField("Auto", text: $carbsTarget)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(AppFonts.body)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Fat")
                            .font(AppFonts.body)
                        Spacer()
                        TextField("Auto", text: $fatTarget)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(AppFonts.body)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Leave empty for automatic calculation based on your profile")
                        .font(AppFonts.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Button(action: saveProfile) {
                        HStack {
                            Spacer()
                            Text("Save Profile")
                                .font(AppFonts.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(isValid ? AppColors.primary : Color.gray)
                        .cornerRadius(AppCornerRadius.medium)
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadProfile()
            }
        }
    }
    
    private var calculatedBMR: Double? {
        guard let weightValue = Double(weight),
              let heightValue = Double(height),
              let ageValue = Int(age),
              weightValue > 0, heightValue > 0, ageValue > 0 else {
            return nil
        }
        
        let user = User(
            name: name,
            gender: gender,
            weight: weightValue,
            height: heightValue,
            age: ageValue,
            activityLevel: activityLevel
        )
        return user.bmr
    }
    
    private var isValid: Bool {
        !name.isEmpty &&
        !weight.isEmpty &&
        !height.isEmpty &&
        !age.isEmpty &&
        Double(weight) != nil &&
        Double(height) != nil &&
        Int(age) != nil
    }
    
    private func loadProfile() {
        if let user = viewModel.user {
            name = user.name
            gender = user.gender
            weight = String(format: "%.1f", user.weight)
            height = String(format: "%.0f", user.height)
            age = "\(user.age)"
            activityLevel = user.activityLevel
            proteinTarget = user.proteinTarget > 0 ? String(format: "%.0f", user.proteinTarget) : ""
            carbsTarget = user.carbsTarget > 0 ? String(format: "%.0f", user.carbsTarget) : ""
            fatTarget = user.fatTarget > 0 ? String(format: "%.0f", user.fatTarget) : ""
        }
    }
    
    private func saveProfile() {
        guard let weightValue = Double(weight),
              let heightValue = Double(height),
              let ageValue = Int(age) else { return }
        
        let proteinTargetValue = Double(proteinTarget) ?? 0
        let carbsTargetValue = Double(carbsTarget) ?? 0
        let fatTargetValue = Double(fatTarget) ?? 0
        
        let user = User(
            name: name,
            gender: gender,
            weight: weightValue,
            height: heightValue,
            age: ageValue,
            activityLevel: activityLevel,
            proteinTarget: proteinTargetValue,
            carbsTarget: carbsTargetValue,
            fatTarget: fatTargetValue
        )
        
        viewModel.saveUser(user)
        dismiss()
    }
}

#Preview {
    ProfileView(viewModel: FoodTrackerViewModel())
}
