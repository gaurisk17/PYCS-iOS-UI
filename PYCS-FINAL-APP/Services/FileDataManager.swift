//
//  FileDataManager.swift
//  PYCS-FINAL-APP
//
//  Created on 4/17/25.
//

import Foundation

// Singleton class to store file URLs and data between views
class FileDataManager {
    // Shared instance
    static let shared = FileDataManager()
    
    // Private initializer for singleton
    private init() {}
    
    // Store the file URLs
    var targetFileURL: URL?
    var boostFileURL: URL?
    var allYearsFileURL: URL?
    var finalYearFileURL: URL?
    var targetYearFileURL: URL?
    
    // Store the latest analysis response
    var latestAnalysisResponse: AnalysisAPIResponse?
    
    // Store actual yield data
    var actualYieldData: [Double] = []
    
    // Reset all data
    func reset() {
        targetFileURL = nil
        boostFileURL = nil
        allYearsFileURL = nil
        finalYearFileURL = nil
        targetYearFileURL = nil
        latestAnalysisResponse = nil
        actualYieldData = []
    }
    
    // Function to read actual yield values from All Years CSV file
    func readActualYieldFromCSV(completion: @escaping (Result<[Double], Error>) -> Void) {
        guard let allYearsFileURL = allYearsFileURL else {
            completion(.failure(NSError(domain: "All Years file URL is missing", code: -1, userInfo: nil)))
            return
        }
        
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
                self.actualYieldData = yields
                completion(.success(yields))
            }
        } catch {
            completion(.failure(error))
        }
    }
}
