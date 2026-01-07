//
//  AnalysisAPIResponse.swift
//  PYCS-FINAL-APP
//
//  Created by Gauri Kulkarni on 4/17/25.
//

//
//  AnalysisAPIResponse.swift
//  PYCS-FINAL-APP
//
//  Created on 4/17/25.
//

import Foundation

// Model to parse the API response based on the actual format
struct AnalysisAPIResponse: Codable {
    let bestParams: BestParams
    let featureImportance: [String: Double]
    let mae: Double
    let mape: Double
    let modelFile: String
    let predictions: [Double]
    let r: Double
    let rmse: Double
    let smape: Double
    
    enum CodingKeys: String, CodingKey {
        case bestParams = "best_params"
        case featureImportance = "feature_importance"
        case mae
        case mape
        case modelFile = "model_file"
        case predictions
        case r
        case rmse
        case smape
    }
}

struct BestParams: Codable {
    let colsampleBytree: Double
    let gamma: Double           // ← now a Double
    let learningRate: Double
    let maxDepth: Double        // ← now a Double
    let minChildWeight: Double  // ← now a Double
    let nEstimators: Double     // ← now a Double
    let regAlpha: Double
    let regLambda: Double
    let subsample: Double
    
    enum CodingKeys: String, CodingKey {
        case colsampleBytree = "colsample_bytree"
        case gamma
        case learningRate = "learning_rate"
        case maxDepth = "max_depth"
        case minChildWeight = "min_child_weight"
        case nEstimators = "n_estimators"
        case regAlpha = "reg_alpha"
        case regLambda = "reg_lambda"
        case subsample
    }
}
