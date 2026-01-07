//
//  ModelListAPIService.swift
//  PYCS-FINAL-APP
//
//  Created by Gauri Kulkarni on 4/17/25.
//

import Foundation

struct ModelResponse: Codable {
    let models: [String]
}

class ModelListAPIService {
    static let shared = ModelListAPIService()
    
    private let baseURL = "https://3.91.83.190.sslip.io/" // Update this with your actual API base URL
    
    private init() {}
    
    func fetchAvailableModels(completion: @escaping (Result<[String], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/models")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "ModelListAPIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }
            
            do {
                let modelResponse = try JSONDecoder().decode(ModelResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(modelResponse.models))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}
