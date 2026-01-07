import SwiftUI
import UniformTypeIdentifiers
import Foundation

struct TestPredictionView: View {
    @State private var showingTestFilePicker = false
    @State private var showingAllYearsFilePicker = false
    @State private var testFileURL: URL? = nil
    @State private var testFileName: String? = "No file selected"
    @State private var allYearsFileURL: URL? = nil
    @State private var allYearsFileName: String? = "No file selected"
    @State private var isAnalyzing = false
    @State private var apiError: String? = nil
    @State private var showAlert = false
    @State private var predictionResult: PredictionResponse? = nil
    @State private var navigateToResults = false
    @State private var actualYield: [Double] = []
    
    // For model selection
    @State private var availableModels: [String] = []
    @State private var selectedModel: String? = nil
    @State private var isLoadingModels = false
    
    // For debugging
    @State private var debugMessages: [String] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.white, Color.blue.opacity(0.1)]),
                             startPoint: .top,
                             endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Upload Test Files")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.horizontal)

                        Text("Please upload the test CSV file and all years CSV file to analyze the prediction results")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        // File Upload Section for Test File (CSV)
                        VStack(spacing: 15) {
                            fileUploadRow(fileName: testFileName ?? "No file selected", description: "Test CSV File", iconName: "doc.text.fill", color: .blue) {
                                showingTestFilePicker = true
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        // File Upload Section for All Years CSV File
                        VStack(spacing: 15) {
                            fileUploadRow(fileName: allYearsFileName ?? "No file selected", description: "All Years CSV File", iconName: "doc.text.fill", color: .purple) {
                                showingAllYearsFilePicker = true
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        // Model Selection Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Model Selection")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if isLoadingModels {
                                HStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                    Text("Loading models...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            } else if availableModels.isEmpty {
                                Text("No models available")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    loadAvailableModels()
                                }) {
                                    Text("Refresh Models")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            } else {
                                Picker("Select Model", selection: $selectedModel) {
                                    Text("Select a model").tag(nil as String?)
                                    ForEach(availableModels, id: \.self) { model in
                                        Text(model).tag(model as String?)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                                
                                if let selectedModel = selectedModel {
                                    Text("Selected: \(selectedModel)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Button(action: {
                                    loadAvailableModels()
                                }) {
                                    Label("Refresh", systemImage: "arrow.clockwise")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)

                        // Analyze Button
                        Button(action: {
                            analyzeData()
                        }) {
                            HStack {
                                Image(systemName: "arrow.up.doc.fill")
                                Text("Analyze Prediction")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(testFileURL != nil && allYearsFileURL != nil && selectedModel != nil ? Color.blue : Color.gray)
                            .cornerRadius(10)
                        }
                        .disabled(testFileURL == nil || allYearsFileURL == nil || selectedModel == nil || isAnalyzing)
                        .padding(.horizontal)

                        if isAnalyzing {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                    .scaleEffect(1.5)
                                Text("Analyzing")
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                            .padding()
                        }
                        
                        #if DEBUG
                        // Debug messages (only in DEBUG mode)
                        if !debugMessages.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Debug Log:")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                ForEach(debugMessages, id: \.self) { message in
                                    Text(message)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                        #endif
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Test Prediction")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                NavigationLink(
                    destination: TestPredictionResults(
                        predictionResult: predictionResult,
                        actualYield: actualYield,
                        times: Array(0..<actualYield.count)
                    ),
                    isActive: $navigateToResults
                ) {
                    EmptyView()
                }
            )
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(apiError ?? "An unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                loadAvailableModels()
            }
        }
        .sheet(isPresented: $showingTestFilePicker) {
            DocumentPicker(types: [.commaSeparatedText, .text]) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        addDebugMessage("Selected test file: \(url.lastPathComponent)")
                        testFileURL = url
                        testFileName = url.lastPathComponent
                    }
                case .failure(let error):
                    addDebugMessage("Test file picker error: \(error.localizedDescription)")
                }
            }
        }
        .sheet(isPresented: $showingAllYearsFilePicker) {
            DocumentPicker(types: [.commaSeparatedText, .text]) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        addDebugMessage("Selected all years file: \(url.lastPathComponent)")
                        allYearsFileURL = url
                        allYearsFileName = url.lastPathComponent
                        
                        // Parse the all years file to get actual yield values
                        parseAllYearsFile(url: url)
                    }
                case .failure(let error):
                    addDebugMessage("All years file picker error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func loadAvailableModels() {
        isLoadingModels = true
        addDebugMessage("Loading available models...")
        
        ModelListAPIService.shared.fetchAvailableModels { result in
            isLoadingModels = false
            
            switch result {
            case .success(let models):
                addDebugMessage("Loaded \(models.count) models")
                self.availableModels = models
                
                // Set the first model as selected if available and none is currently selected
                if self.selectedModel == nil, let firstModel = models.first {
                    self.selectedModel = firstModel
                    addDebugMessage("Auto-selected model: \(firstModel)")
                }
                
            case .failure(let error):
                addDebugMessage("Error loading models: \(error.localizedDescription)")
                apiError = "Failed to load models: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
    
    private func addDebugMessage(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logMessage = "[\(timestamp)] \(message)"
        print(logMessage)
        debugMessages.insert(logMessage, at: 0)
        
        // Keep only the last 10 messages
        if debugMessages.count > 10 {
            debugMessages = Array(debugMessages.prefix(10))
        }
    }
    
    private func parseAllYearsFile(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            
            if let csvString = String(data: data, encoding: .utf8) {
                // Simple CSV parser - assuming comma-separated values
                let rows = csvString.components(separatedBy: .newlines)
                
                addDebugMessage("CSV file has \(rows.count) rows")
                
                // Try to find the yield column
                var yieldColumnIndex = -1
                if rows.count > 0 {
                    let headerRow = rows[0]
                    let columns = headerRow.components(separatedBy: ",")
                    
                    for (index, column) in columns.enumerated() {
                        let cleanColumn = column.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                        if cleanColumn == "yield" {
                            yieldColumnIndex = index
                            addDebugMessage("Found yield column at index \(index)")
                            break
                        }
                    }
                }
                
                // Extract yield values
                var yields: [Double] = []
                
                // Skip header row
                for i in 1..<rows.count {
                    let row = rows[i]
                    if row.isEmpty { continue }
                    
                    let columns = row.components(separatedBy: ",")
                    
                    if yieldColumnIndex >= 0 && yieldColumnIndex < columns.count {
                        // We know which column has yield
                        if let yield = Double(columns[yieldColumnIndex].trimmingCharacters(in: .whitespacesAndNewlines)) {
                            yields.append(yield)
                        }
                    } else {
                        // Try to find a numeric value in any column
                        for column in columns {
                            if let yield = Double(column.trimmingCharacters(in: .whitespacesAndNewlines)) {
                                yields.append(yield)
                                break
                            }
                        }
                    }
                }
                
                if yields.isEmpty {
                    addDebugMessage("Failed to extract any yield values from CSV")
                    apiError = "Failed to extract yield values from the all years file"
                    showAlert = true
                } else {
                    addDebugMessage("Extracted \(yields.count) yield values")
                    self.actualYield = yields
                }
            }
        } catch {
            addDebugMessage("Error reading all years file: \(error.localizedDescription)")
            apiError = "Error reading all years file: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func analyzeData() {
        guard let testFileURL = testFileURL else {
            apiError = "Please select a test file"
            showAlert = true
            return
        }
        
        guard !actualYield.isEmpty else {
            apiError = "No yield data found in the all years file"
            showAlert = true
            return
        }
        
        guard let modelName = selectedModel else {
            apiError = "Please select a model"
            showAlert = true
            return
        }
        
        isAnalyzing = true
        addDebugMessage("Starting API request to analyze data with model: \(modelName)")
        
        // Make the real API call
        PredictionAPIService.shared.predictYield(testFile: testFileURL, modelName: modelName) { result in
            isAnalyzing = false
            
            switch result {
            case .success(let response):
                addDebugMessage("API Success: MAE=\(response.mae), RMSE=\(response.rmse)")
                self.predictionResult = response
                self.navigateToResults = true
                
            case .failure(let error):
                addDebugMessage("API Error: \(error.localizedDescription)")
                self.apiError = error.localizedDescription
                self.showAlert = true
            }
        }
    }

    // Helper function to create file upload rows
    private func fileUploadRow(fileName: String, description: String, iconName: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(description)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(fileName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.blue)
                    .font(.title3)
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
        }
    }
}

struct TestPredictionView_Previews: PreviewProvider {
    static var previews: some View {
        TestPredictionView()
    }
}
