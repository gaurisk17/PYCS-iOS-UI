//
//  HelpView.swift
//  PYCS-FINAL-APP
//
//  Created by Gauri Kulkarni on 4/14/25.
//  Updated on 4/17/25.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToDashboard = false
    
    let sections = [
        HelpSection(
            title: "Actual vs Predicted Yield",
            icon: "chart.line.uptrend.xyaxis",
            color: .blue,
            description: "This chart compares historical yield data with model predictions over time to show the accuracy of our forecasting system.",
            points: [
                "Blue circles show actual historical yields (tons per hectare)",
                "Red squares represent the model's predictions",
                "The closer these points align, the more accurate our prediction model",
                "Time index represents sequential growing periods (e.g., years or seasons)"
            ]
        ),
        HelpSection(
            title: "Feature Importance",
            icon: "list.bullet.rectangle.portrait.fill",
            color: .green,
            description: "This bar chart shows which environmental and agricultural factors have the greatest influence on predicting crop yield.",
            points: [
                "Longer bars indicate factors with stronger influence on crop yield",
                "Factors typically include temperature, rainfall, soil conditions, and other variables",
                "This helps identify which conditions to monitor most closely",
                "The model automatically identifies these relationships from your historical data"
            ]
        ),
        HelpSection(
            title: "Evaluation Metrics",
            icon: "ruler.fill",
            color: .purple,
            description: "These statistical measures indicate how reliable our prediction model is based on historical data comparison.",
            points: [
                "MAE (Mean Absolute Error): Average error in tons per hectare (lower is better)",
                "RMSE (Root Mean Square Error): Error measure that penalizes larger mistakes (lower is better)",
                "MAPE & SMAPE: Error expressed as percentages relative to actual yields (lower is better)",
                "Correlation: How closely predictions match actual results on a scale of -1 to 1 (higher is better)"
            ]
        ),
        HelpSection(
            title: "Model Parameters",
            icon: "gearshape.2.fill",
            color: .orange,
            description: "These technical settings determine how our machine learning model processes your data to make predictions.",
            points: [
                "Learning Rate: Controls how quickly the model adapts to the training data",
                "Max Depth: Defines the complexity of patterns the model can identify",
                "Estimators: Number of predictive models combined for the final prediction",
                "Subsample & Col Sample: Control which data points and features are used for training",
                "These parameters are automatically optimized for your specific crops and conditions"
            ]
        ),
        HelpSection(
            title: "Interpreting Results",
            icon: "lightbulb.fill",
            color: .yellow,
            description: "How to use these predictions for practical farm management and planning.",
            points: [
                "Predictions help with harvest timing, resource allocation, and market planning",
                "Compare predicted yields with previous seasons to identify trends",
                "Use feature importance to focus on the most impactful growing conditions",
                "The model accuracy improves over time as more of your farm data is incorporated",
                "Consider these predictions as a tool to complement, not replace, your farming expertise"
            ]
        )
    ]
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Understanding Your Analysis Results")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("A guide to interpreting your crop yield predictions and model insights")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Main content sections
                    ForEach(sections) { section in
                        HelpSectionView(section: section)
                    }
                    
                    // Additional help note
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About the Prediction Model")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("PYCS uses machine learning algorithms (specifically gradient boosting) to analyze patterns in historical crop data and environmental conditions. The system identifies relationships between various factors and yield outcomes to make future predictions.")
                            .font(.body)
                            .padding(.bottom, 8)
                        
                        Text("Each time you upload new data or retrain the model, it refines its understanding of your specific growing conditions, becoming increasingly accurate over time.")
                            .font(.body)
                            .padding(.bottom, 8)
                        
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title3)
                            
                            Text("For optimal results, provide consistent data over multiple growing seasons.")
                                .font(.body.italic())
                                .foregroundColor(.primary)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Return to dashboard button
                    Button(action: {
                        navigateToDashboard = true
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                                .font(.system(size: 16))
                            Text("Return to Dashboard")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.green, .green.opacity(0.8)]),
                                         startPoint: .leading,
                                         endPoint: .trailing)
                        )
                        .cornerRadius(15)
                        .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
                .padding(.vertical)
            }
            
            // Dashboard navigation link (hidden)
            NavigationLink(destination: DashboardView().navigationBarBackButtonHidden(true), isActive: $navigateToDashboard) {
                EmptyView()
            }
        }
        .navigationTitle("Help & Explanations")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    dismiss()
                }) {
                    Text("Done")
                        .fontWeight(.bold)
                }
            }
        }
    }
}

// Model for help section data
struct HelpSection: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let description: String
    let points: [String]
}

// Reusable view for each help section
struct HelpSectionView: View {
    let section: HelpSection
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header (always visible)
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: section.icon)
                        .font(.title2)
                        .foregroundColor(section.color)
                        .frame(width: 30, height: 30)
                    
                    Text(section.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.callout)
                        .padding(.trailing, 4)
                }
            }
            .padding(.vertical, 8)
            
            // Expandable content
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Text(section.description)
                        .font(.body)
                        .padding(.bottom, 4)
                    
                    ForEach(section.points, id: \.self) { point in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(section.color)
                                .font(.system(size: 14))
                                .frame(width: 16, height: 16)
                                .padding(.top, 2)
                            
                            Text(point)
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.leading, 10)
                .padding(.top, 8)
                .transition(.opacity)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
        .onAppear {
            // Start with first section expanded
            if section.title == "Actual vs Predicted Yield" {
                isExpanded = true
            }
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HelpView()
        }
    }
}
