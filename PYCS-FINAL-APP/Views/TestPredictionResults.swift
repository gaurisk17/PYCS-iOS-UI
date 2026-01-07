import SwiftUI
import Charts

struct TestPredictionResults: View {
    // Prediction results from API
    let predictionResult: PredictionResponse?
    
    // Actual yield data from all years CSV
    let actualYield: [Double]
    let times: [Int]
    
    // Derived feature importance data from API response
    var featureNames: [String] {
        return predictionResult?.featureImportance?.keys.sorted(by: {
            (predictionResult?.featureImportance?[$0] ?? 0) >
            (predictionResult?.featureImportance?[$1] ?? 0)
        }) ?? []
    }
    
    var featureImportance: [Double] {
        return featureNames.map { predictionResult?.featureImportance?[$0] ?? 0 }
    }
    
    // Color scheme for better UI
    let actualColor = Color.blue
    let predictedColor = Color.red
    let featureColor = Color(red: 0.2, green: 0.6, blue: 0.3)
    let backgroundColor = Color(UIColor.systemBackground)
    let cardBackgroundColor = Color(UIColor.secondarySystemBackground)
    
    @State private var showingHelpView = false
    
    init(predictionResult: PredictionResponse?, actualYield: [Double], times: [Int]) {
        self.predictionResult = predictionResult
        self.actualYield = actualYield
        self.times = times
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Model information
                if let modelFile = predictionResult?.modelFile {
                    VStack(alignment: .leading) {
                        Text("Model: \(modelFile)")
                            .font(.headline)
                            .padding(.horizontal)
                    }
                }
                
                // Chart for Actual vs Predicted Yield
                VStack(alignment: .leading, spacing: 8) {
                    Text("Actual vs Predicted Yield Over Time")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    PredictionChartsService.createLegend(
                        actualColor: actualColor,
                        predictedColor: predictedColor
                    )
                    
                    PredictionChartsService.createYieldChart(
                        actualYield: actualYield,
                        predictionResult: predictionResult,
                        actualColor: actualColor,
                        predictedColor: predictedColor,
                        cardBackgroundColor: cardBackgroundColor
                    )
                }
                
                // Only show Feature Importance if we have data
                if !featureNames.isEmpty && !featureImportance.isEmpty {
                    // Feature Importance Chart
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Feature Importance")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        PredictionChartsService.createFeatureImportanceChart(
                            featureNames: featureNames,
                            featureImportance: featureImportance,
                            featureColor: featureColor,
                            cardBackgroundColor: cardBackgroundColor
                        )
                    }
                }
                
                // Displaying Evaluation Metrics in a grid
                if let result = predictionResult {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Evaluation Metrics")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            // Fixed the unwrapping issue by providing a default value when optional is nil
                            PredictionChartsService.metricCard(
                                title: "MAE",
                                value: result.mae ?? 0, // Safely unwrap the optional
                                format: "%.3f",
                                cardBackgroundColor: cardBackgroundColor
                            )
                            
                            PredictionChartsService.metricCard(
                                title: "RMSE",
                                value: result.rmse ?? 0, // Safely unwrap the optional
                                format: "%.3f",
                                cardBackgroundColor: cardBackgroundColor
                            )
                            
                            // Continue safely unwrapping other optional metrics
                            PredictionChartsService.metricCard(
                                title: "MAPE",
                                value: result.mape ?? 0,
                                format: "%.1f%%",
                                cardBackgroundColor: cardBackgroundColor
                            )
                            
                            PredictionChartsService.metricCard(
                                title: "SMAPE",
                                value: result.smape ?? 0,
                                format: "%.1f%%",
                                cardBackgroundColor: cardBackgroundColor
                            )
                        }
                        .padding(.horizontal)
                        
                        PredictionChartsService.metricCard(
                            title: "Correlation",
                            value: result.r ?? 0, // Safely unwrap the optional
                            format: "%.3f",
                            cardBackgroundColor: cardBackgroundColor
                        )
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Prediction Results")
        .navigationBarTitleDisplayMode(.inline)
        .background(backgroundColor)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingHelpView = true
                }) {
                    Label("Help", systemImage: "questionmark.circle")
                }
            }
        }
        .sheet(isPresented: $showingHelpView) {
            NavigationView {
                HelpView()
            }
        }
    }
}
