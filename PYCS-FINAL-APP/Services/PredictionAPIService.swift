//
//  PredictionAPIService.swift
//  PYCS-FINAL-APP
//
//  Created by Gauri Kulkarni on 4/17/25.
//

import Foundation

struct PredictionResponse: Codable {
    let modelFile: String
    let predictions: [Double]
    let mae: Double?
    let r: Double?
    let mape: Double?
    let smape: Double?
    let rmse: Double?
    let featureImportance: [String: Double]?
    
    enum CodingKeys: String, CodingKey {
        case modelFile = "model_file"
        case predictions
        case mae
        case r
        case mape
        case smape
        case rmse
        case featureImportance = "feature_importance"
    }
}

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingError(let error):
            return "Error decoding response: \(error.localizedDescription)"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}

class PredictionAPIService {
    static let shared = PredictionAPIService()
    
    private let baseURL = "https://3.91.83.190.sslip.io" // Update this with your actual API base URL
    
    private init() {}
    
    func predictYield(testFile: URL, modelName: String, completion: @escaping (Result<PredictionResponse, APIError>) -> Void) {
        // Create URL for the request
        guard let url = URL(string: "\(baseURL)/predict?model_name=\(modelName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Create multipart form data request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create the data for the files
        var data = Data()
        
        // Add test file
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"test_file\"; filename=\"\(testFile.lastPathComponent)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: text/csv\r\n\r\n".data(using: .utf8)!)
        
        do {
            let testFileData = try Data(contentsOf: testFile)
            data.append(testFileData)
            data.append("\r\n".data(using: .utf8)!)
        } catch {
            completion(.failure(.networkError(error)))
            return
        }
        
        // End of form data
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Create the upload task
        let task = URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error)))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }
            
            guard httpResponse.statusCode == 200, let responseData = responseData else {
                let responseString = responseData != nil ? String(data: responseData!, encoding: .utf8) ?? "Unknown error" : "Unknown error"
                DispatchQueue.main.async {
                    completion(.failure(.serverError(responseString)))
                }
                return
            }
            
            do {
                let predictionResponse = try JSONDecoder().decode(PredictionResponse.self, from: responseData)
                DispatchQueue.main.async {
                    completion(.success(predictionResponse))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError(error)))
                }
            }
        }
        
        task.resume()
    }
}
