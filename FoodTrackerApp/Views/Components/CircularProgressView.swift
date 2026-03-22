//
//  CircularProgressView.swift
//  FoodTrackerApp
//
//  Created by Template
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double // 0.0 to 1.0
    let color: Color
    let lineWidth: CGFloat
    let size: CGFloat
    
    init(progress: Double, color: Color, lineWidth: CGFloat = 12, size: CGFloat = 80) {
        self.progress = min(max(progress, 0), 1.0) // Clamp between 0 and 1
        self.color = color
        self.lineWidth = lineWidth
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
        }
        .frame(width: size, height: size)
    }
}

struct MacroProgressCard: View {
    let label: String
    let current: Double
    let target: Double
    let color: Color
    let unit: String
    
    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.0)
    }
    
    private var percentage: Int {
        guard target > 0 else { return 0 }
        return Int((current / target) * 100)
    }
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Text(label)
                .font(AppFonts.caption)
                .foregroundColor(.secondary)
            
            ZStack {
                CircularProgressView(
                    progress: progress,
                    color: color,
                    lineWidth: 10,
                    size: 90
                )
                
                VStack(spacing: 2) {
                    Text("\(Int(current))")
                        .font(AppFonts.headline)
                        .foregroundColor(color)
                    Text("/ \(Int(target))\(unit)")
                        .font(AppFonts.caption2)
                        .foregroundColor(.secondary)
                    Text("\(percentage)%")
                        .font(AppFonts.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .background(color.opacity(0.1))
        .cornerRadius(AppCornerRadius.medium)
    }
}

#Preview {
    HStack(spacing: AppSpacing.md) {
        MacroProgressCard(
            label: "Protein",
            current: 120,
            target: 150,
            color: AppColors.protein,
            unit: "g"
        )
        
        MacroProgressCard(
            label: "Carbs",
            current: 200,
            target: 250,
            color: AppColors.carbs,
            unit: "g"
        )
        
        MacroProgressCard(
            label: "Fat",
            current: 60,
            target: 80,
            color: AppColors.fat,
            unit: "g"
        )
    }
    .padding()
}

