import SwiftUI
import Charts

// Model to parse the API response (same as in API service)
// Update PredictionResponse struct in PredictionChartsService.swift

// Service class for chart generation
class PredictionChartsService {
    static func createYieldChart(
        actualYield: [Double],
        predictionResult: PredictionResponse?,
        actualColor: Color,
        predictedColor: Color,
        cardBackgroundColor: Color
    ) -> some View {
        let maxYValue = max(
            actualYield.max() ?? 5.0,
            (predictionResult?.predictions.max() ?? 5.0)
        ) + 0.5
        
        // Calculate total time range
        let totalPointCount = actualYield.count
        
        // Calculate where predictions should start (if we have predictions)
        let predictionStartIndex = predictionResult?.predictions != nil ?
            max(0, totalPointCount - predictionResult!.predictions.count) :
            totalPointCount
        
        return Chart {
            // Actual yield line (only up to where predictions start)
            ForEach(0..<predictionStartIndex, id: \.self) { i in
                LineMark(
                    x: .value("Time Index", i),
                    y: .value("Yield (t/ha)", actualYield[i])
                )
                .foregroundStyle(actualColor)
                .interpolationMethod(.linear)
            }
            
            // Actual yield points (only up to where predictions start)
            ForEach(0..<predictionStartIndex, id: \.self) { i in
                PointMark(
                    x: .value("Time Index", i),
                    y: .value("Yield (t/ha)", actualYield[i])
                )
                .foregroundStyle(actualColor)
                .symbol(.circle)
                .symbolSize(40)
            }
            
            // Predicted yield line
            if let predictions = predictionResult?.predictions {
                let count = min(predictions.count, totalPointCount - predictionStartIndex)
                
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
        }
        .chartXScale(domain: -1...totalPointCount)
        .chartYScale(domain: 0...maxYValue)
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
    
    static func createFeatureImportanceChart(
        featureNames: [String],
        featureImportance: [Double],
        featureColor: Color,
        cardBackgroundColor: Color
    ) -> some View {
        Chart {
            ForEach(0..<featureNames.count, id: \.self) { i in
                BarMark(
                    x: .value("Importance", featureImportance[i]),
                    y: .value("Feature", featureNames[i])
                )
                .foregroundStyle(featureColor)
                .cornerRadius(6)
            }
        }
        .chartXScale(domain: 0...0.5)
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
    
    static func createLegend(
        actualColor: Color,
        predictedColor: Color
    ) -> some View {
        HStack(spacing: 24) {
            HStack(spacing: 8) {
                Circle()
                    .fill(actualColor)
                    .frame(width: 12, height: 12)
                Text("Actual Yield")
                    .font(.subheadline)
            }
            
            HStack(spacing: 8) {
                Rectangle()
                    .fill(predictedColor)
                    .frame(width: 12, height: 12)
                Text("Predicted Yield")
                    .font(.subheadline)
            }
        }
        .padding(.horizontal)
    }
    
    static func metricCard(
        title: String,
        value: Double,
        format: String,
        cardBackgroundColor: Color
    ) -> some View {
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
}
