//
//  AnalysisResultsView.swift
//  PYCS-FINAL-APP
//
//  Created by Gauri Kulkarni on 4/13/25.
//  Updated on 4/17/25.
//

import SwiftUI
import Charts

struct AnalysisResultsView: View {
    // State properties to store data from the API
    @State private var analysisResponse: AnalysisAPIResponse?
    @State private var actualYield: [Double] = []
    @State private var timeIndices: [Int] = []
    @State private var showingHelpView = false
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var navigateToDashboard = false
    
    // Color scheme for better UI
    private let actualColor = Color.blue
    private let predictedColor = Color.red
    private let featureColor = Color(red: 0.2, green: 0.6, blue: 0.3)
    private let backgroundColor = Color(UIColor.systemBackground)
    private let cardBackgroundColor = Color(UIColor.secondarySystemBackground)
    
    // API service
    private let apiService = AnalyzeDataAPIService()
    // Data manager
    private let dataManager = FileDataManager.shared
    
    var body: some View {
        ZStack {
            Group {
                if isLoading {
                    loadingView
                } else if let error = errorMessage {
                    errorView(message: error)
                } else {
                    contentView
                }
            }
            
            // Dashboard navigation link (hidden)
            NavigationLink(destination: DashboardView().navigationBarBackButtonHidden(true), isActive: $navigateToDashboard) {
                EmptyView()
            }
            
            // Dashboard floating button
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        navigateToDashboard = true
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                                .font(.system(size: 16))
                            Text("Dashboard")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                                          startPoint: .leading,
                                          endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(25)
                        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            // Fetch data from API when view appears
            fetchAnalysisData()
        }
        .navigationTitle("Analysis Results")
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
    
    // Loading view
    private var loadingView: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.5)
            
            Text("Loading analysis results...")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding()
        }
    }
    
    // Error view
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Error Loading Data")
                .font(.title)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                isLoading = true
                errorMessage = nil
                fetchAnalysisData()
            }) {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Button(action: {
                navigateToDashboard = true
            }) {
                Text("Return to Dashboard")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.top, 10)
            }
        }
        .padding()
    }
    
    // Main content view
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 24) {
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
                    
                    if let response = analysisResponse {
                        createYieldChart(
                            actualYield: actualYield,
                            predictions: response.predictions,
                            actualColor: actualColor,
                            predictedColor: predictedColor
                        )
                    }
                }
                
                // Feature Importance Chart
                if let response = analysisResponse {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Feature Importance")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        let featureNames = Array(response.featureImportance.keys)
                        let featureValues = featureNames.map { response.featureImportance[$0] ?? 0.0 }
                        
                        createFeatureImportanceChart(
                            featureNames: featureNames,
                            featureImportance: featureValues
                        )
                    }
                }
                
                // Displaying Evaluation Metrics
                if let response = analysisResponse {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Evaluation Metrics")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            metricCard(title: "MAE", value: response.mae, format: "%.3f")
                            metricCard(title: "RMSE", value: response.rmse, format: "%.3f")
                            metricCard(title: "MAPE", value: response.mape, format: "%.1f%%")
                            metricCard(title: "SMAPE", value: response.smape, format: "%.1f%%")
                        }
                        .padding(.horizontal)
                        
                        metricCard(title: "Correlation", value: response.r, format: "%.3f")
                            .padding(.horizontal)
                    }
                }
                
                // Best Parameters Section
                if let params = analysisResponse?.bestParams {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Model Parameters")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                parameterCard(title: "Learning Rate", value: "\(params.learningRate)")
                                parameterCard(title: "Max Depth", value: "\(params.maxDepth)")
                                parameterCard(title: "Estimators", value: "\(params.nEstimators)")
                                parameterCard(title: "Subsample", value: "\(params.subsample)")
                                parameterCard(title: "Col Sample", value: "\(params.colsampleBytree)")
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
                
                // Dashboard button (inline)
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
                .padding(.bottom, 80) // Add padding at the bottom to avoid floating button overlap
            }
            .padding()
        }
    }
    
    // Helper method to create the yield chart
    private func createYieldChart(
        actualYield: [Double],
        predictions: [Double],
        actualColor: Color,
        predictedColor: Color
    ) -> some View {
        // Find min and max values to set appropriate Y axis scale
        let allValues = actualYield + predictions
        let minValue = (allValues.min() ?? 0.0) - 1.0 // Add padding below
        let maxValue = (allValues.max() ?? 5.0) + 0.5 // Add padding above
        
        // Calculate total time range
        let totalPointCount = actualYield.count
        
        // Calculate where predictions should start
        let predictionStartIndex = max(0, totalPointCount - predictions.count)
        
        return Chart {
            // Actual yield line
            ForEach(0..<actualYield.count, id: \.self) { i in
                LineMark(
                    x: .value("Time Index", i),
                    y: .value("Yield (t/ha)", actualYield[i])
                )
                .foregroundStyle(actualColor)
                .interpolationMethod(.linear)
            }
            
            // Actual yield points
            ForEach(0..<actualYield.count, id: \.self) { i in
                PointMark(
                    x: .value("Time Index", i),
                    y: .value("Yield (t/ha)", actualYield[i])
                )
                .foregroundStyle(actualColor)
                .symbol(.circle)
                .symbolSize(40)
            }
            
            // Predicted yield line
            let count = predictions.count
            
            ForEach(0..<count, id: \.self) { i in
                LineMark(
                    x: .value("Time Index", predictionStartIndex + i),
                    y: .value("Yield (t/ha)", predictions[i])
                )
                .foregroundStyle(predictedColor)
                .interpolationMethod(.linear)
            }
            
            // Predicted yield points
            ForEach(0..<count, id: \.self) { i in
                PointMark(
                    x: .value("Time Index", predictionStartIndex + i),
                    y: .value("Yield (t/ha)", predictions[i])
                )
                .foregroundStyle(predictedColor)
                .symbol(.square)
                .symbolSize(40)
            }
        }
        .chartXScale(domain: -1...totalPointCount)
        .chartYScale(domain: minValue...maxValue) // Use calculated min/max values
        .chartXAxis {
            AxisMarks(position: .bottom, values: .automatic) {
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: []))
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic) {
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: []))
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartXAxisLabel("Time Index")
        .chartYAxisLabel("Yield (t/ha)")
        .frame(height: 350)
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // Helper method to create the feature importance chart
    private func createFeatureImportanceChart(
        featureNames: [String],
        featureImportance: [Double]
    ) -> some View {
        // Find max importance value to set appropriate X axis scale
        let maxImportance = (featureImportance.max() ?? 0.4) + 0.05
        
        return Chart {
            ForEach(0..<featureNames.count, id: \.self) { i in
                BarMark(
                    x: .value("Importance", featureImportance[i]),
                    y: .value("Feature", featureNames[i])
                )
                .foregroundStyle(featureColor)
                .cornerRadius(6)
            }
        }
        .chartXScale(domain: 0...maxImportance) // Use calculated max value
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisValueLabel()
            }
        }
        .chartXAxisLabel("Relative Importance")
        .chartYAxisLabel("Feature")
        .frame(height: 300)
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // Evaluation metric card
    private func metricCard(title: String, value: Double, format: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(String(format: format, value))
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
    }
    
    // Parameter card
    private func parameterCard(title: String, value: String) -> some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .frame(minWidth: 100)
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
    }
    
    // Fetch data from API
    private func fetchAnalysisData() {
        // First check if we have data in the manager
        if let response = dataManager.latestAnalysisResponse {
            self.analysisResponse = response
            
            // Check if we have actual yield data
            if !dataManager.actualYieldData.isEmpty {
                self.actualYield = dataManager.actualYieldData
                self.timeIndices = Array(0..<dataManager.actualYieldData.count)
                self.isLoading = false
                return
            }
            
            // Try to read actual yield data from CSV
            if let allYearsFileURL = dataManager.allYearsFileURL {
                dataManager.readActualYieldFromCSV { result in
                    switch result {
                    case .success(let yields):
                        self.actualYield = yields
                        self.timeIndices = Array(0..<yields.count)
                    case .failure(let error):
                        print("Error reading CSV: \(error.localizedDescription)")
                        // Set a default empty array if reading fails
                        self.actualYield = []
                        self.timeIndices = []
                    }
                    self.isLoading = false
                }
            } else {
                // No CSV file available
                self.actualYield = []
                self.timeIndices = []
                self.isLoading = false
            }
        } else {
            // Use API service to fetch results
            apiService.fetchAnalysisResults { result in
                switch result {
                case .success(let response):
                    self.analysisResponse = response
                    self.dataManager.latestAnalysisResponse = response
                    
                    // Try to get actual yields from CSV file
                    if let allYearsFileURL = self.dataManager.allYearsFileURL {
                        self.dataManager.readActualYieldFromCSV { csvResult in
                            self.isLoading = false
                            
                            switch csvResult {
                            case .success(let yields):
                                self.actualYield = yields
                                self.timeIndices = Array(0..<yields.count)
                            case .failure(let error):
                                self.errorMessage = "Failed to read yield data: \(error.localizedDescription)"
                            }
                        }
                    } else {
                        self.isLoading = false
                        self.errorMessage = "All-years file not found. Please upload files again."
                    }
                    
                case .failure(let error):
                    self.isLoading = false
                    self.errorMessage = "Failed to fetch analysis results: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct AnalysisResultsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnalysisResultsView()
        }
    }
}
