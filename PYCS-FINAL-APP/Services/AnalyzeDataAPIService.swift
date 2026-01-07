//
//  AnalyzeDataAPIService.swift
//  PYCS-FINAL-APP
//
//  Created on 4/17/25.
//

import Foundation
import Combine

class AnalyzeDataAPIService {
    // Base URL for the API
    private let baseURL = "https://3.91.83.190.sslip.io"
    private let analysisResultsURL = "https://3.91.83.190.sslip.io"
    
    // Function to upload files and get analysis results
    func uploadFilesForAnalysis(
        targetFileURL: URL,
        boostFileURL: URL,
        allYearsFileURL: URL,
        finalYearFileURL: URL,
        targetYearFileURL: URL,
        completion: @escaping (Result<AnalysisAPIResponse, Error>) -> Void
    ) {
        // Create URL request
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Generate boundary string
        let boundary = UUID().uuidString
        
        // Set the Content-Type header to multipart/form-data with the boundary
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Prepare file URLs in a dictionary for easier handling
        let fileURLs: [String: URL] = [
            "target_file": targetFileURL,
            "boost_file": boostFileURL,
            "all_years_file": allYearsFileURL,
            "final_year_file": finalYearFileURL,
            "target_year_file": targetYearFileURL
        ]
        
        // Create multipart form data body
        let httpBody = NSMutableData()
        
        // Add each file to the request body
        for (fieldName, fileURL) in fileURLs {
            httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            httpBody.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
            httpBody.append("Content-Type: text/csv\r\n\r\n".data(using: .utf8)!)
            
            do {
                let fileData = try Data(contentsOf: fileURL)
                httpBody.append(fileData)
                httpBody.append("\r\n".data(using: .utf8)!)
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        // Add the final boundary
        httpBody.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Set the request body
        request.httpBody = httpBody as Data
        
        // Create and start the data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                }
                return
            }
            
            do {
                let analysisResponse = try JSONDecoder().decode(AnalysisAPIResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(analysisResponse))
                }
            } catch {
                DispatchQueue.main.async {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    // Function to fetch analysis results
    func fetchAnalysisResults(completion: @escaping (Result<AnalysisAPIResponse, Error>) -> Void) {
        guard let url = URL(string: analysisResultsURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                }
                return
            }
            
            do {
                let analysisResponse = try JSONDecoder().decode(AnalysisAPIResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(analysisResponse))
                }
            } catch {
                DispatchQueue.main.async {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    // Function to read actual yield values from All Years CSV file
    func readActualYieldFromCSV(allYearsFileURL: URL, completion: @escaping (Result<[Double], Error>) -> Void) {
        do {
            let csvContent = try String(contentsOf: allYearsFileURL, encoding: .utf8)
            let rows = csvContent.components(separatedBy: .newlines)
            
            guard rows.count > 1 else {
                completion(.failure(NSError(domain: "Invalid CSV format", code: -1, userInfo: nil)))
                return
            }
            
            // Find the yield column index
            let headers = rows[0].components(separatedBy: ",")
            guard let yieldIndex = headers.firstIndex(where: { $0.lowercased().contains("yield") }) else {
                completion(.failure(NSError(domain: "Yield column not found", code: -1, userInfo: nil)))
                return
            }
            
            // Extract yield values
            var yields: [Double] = []
            for i in 1..<rows.count {
                let row = rows[i]
                if row.isEmpty { continue }
                
                let columns = row.components(separatedBy: ",")
                if columns.count > yieldIndex, let yield = Double(columns[yieldIndex]) {
                    yields.append(yield)
                }
            }
            
            if yields.isEmpty {
                completion(.failure(NSError(domain: "No yield values found", code: -1, userInfo: nil)))
            } else {
                completion(.success(yields))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // Function to check if all required files are selected
    static func areAllFilesSelected(
        targetFileName: String?,
        boostFileName: String?,
        allYearsFileName: String?,
        finalYearFileName: String?,
        targetYearFileName: String?
    ) -> Bool {
        return targetFileName != nil && targetFileName != "No file selected" &&
               boostFileName != nil && boostFileName != "No file selected" &&
               allYearsFileName != nil && allYearsFileName != "No file selected" &&
               finalYearFileName != nil && finalYearFileName != "No file selected" &&
               targetYearFileName != nil && targetYearFileName != "No file selected"
    }
}
