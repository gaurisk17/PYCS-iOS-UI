//
//  AnalyzeDataView.swift
//  PYCS-FINAL-APP
//
//  Created by Gauri Kulkarni on 4/13/25.
//  Updated on 4/17/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct AnalyzeDataView: View {
    @State private var showingTargetFilePicker = false
    @State private var showingBoostFilePicker = false
    @State private var showingAllYearsFilePicker = false
    @State private var showingFinalYearFilePicker = false
    @State private var showingTargetYearFilePicker = false
    @State private var isUploading = false
    @State private var showAnalysisCompleted = false
    @State private var pickleFileName = ""
    @State private var errorMessage: String? = nil
    @State private var showErrorAlert = false

    // For custom document picker
    @State private var showCustomDocumentPicker = false
    @State private var currentFileType: FileType?

    // Store the file names and URLs
    @State private var targetFileName: String? = "No file selected"
    @State private var boostFileName: String? = "No file selected"
    @State private var allYearsFileName: String? = "No file selected"
    @State private var finalYearFileName: String? = "No file selected"
    @State private var targetYearFileName: String? = "No file selected"

    // Store the URLs for API upload
    @State private var targetFileURL: URL? = nil
    @State private var boostFileURL: URL? = nil
    @State private var allYearsFileURL: URL? = nil
    @State private var finalYearFileURL: URL? = nil
    @State private var targetYearFileURL: URL? = nil

    enum FileType {
        case targetFile, boostFile, allYearsFile, finalYearFile, targetYearFile
    }

    // API service instance
    private let apiService = AnalyzeDataAPIService()

    // Computed property to check if all files are selected
    private var allFilesSelected: Bool {
        return AnalyzeDataAPIService.areAllFilesSelected(
            targetFileName: targetFileName,
            boostFileName: boostFileName,
            allYearsFileName: allYearsFileName,
            finalYearFileName: finalYearFileName,
            targetYearFileName: targetYearFileName
        )
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.white, Color.blue.opacity(0.1)]),
                             startPoint: .top,
                             endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Analyze Crop Data")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.horizontal)

                        Text("Please upload all required CSV files to analyze crop yield")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        // File Upload Section
                        VStack(spacing: 15) {
                            fileUploadRow(fileName: targetFileName ?? "No file selected", description: "Target File", iconName: "doc.text.fill", color: .blue) {
                                currentFileType = .targetFile
                                showCustomDocumentPicker = true
                            }

                            fileUploadRow(fileName: boostFileName ?? "No file selected", description: "Boost File", iconName: "doc.text.fill", color: .orange) {
                                currentFileType = .boostFile
                                showCustomDocumentPicker = true
                            }

                            fileUploadRow(fileName: allYearsFileName ?? "No file selected", description: "All Years File", iconName: "doc.text.fill", color: .purple) {
                                currentFileType = .allYearsFile
                                showCustomDocumentPicker = true
                            }

                            fileUploadRow(fileName: finalYearFileName ?? "No file selected", description: "Final Year File", iconName: "doc.text.fill", color: .green) {
                                currentFileType = .finalYearFile
                                showCustomDocumentPicker = true
                            }

                            fileUploadRow(fileName: targetYearFileName ?? "No file selected", description: "Target Year File", iconName: "doc.text.fill", color: .red) {
                                currentFileType = .targetYearFile
                                showCustomDocumentPicker = true
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)

                        // Analyze Data Button
                        Button(action: {
                            uploadFilesForAnalysis()
                        }) {
                            HStack {
                                Image(systemName: "arrow.up.doc.fill")
                                Text("Analyze Data")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(allFilesSelected ? Color.blue : Color.gray)
                            .cornerRadius(10)
                        }
                        .disabled(!allFilesSelected || isUploading)
                        .padding(.horizontal)

                        if isUploading {
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
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Analyze Crop Data")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage ?? "An unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
            // Navigation links for different views
            .background(
                Group {
                    NavigationLink(
                        destination: AnalysisCompletedView(pickleFileName: pickleFileName),
                        isActive: $showAnalysisCompleted
                    ) { EmptyView() }
                }
            )
        }
        .sheet(isPresented: $showCustomDocumentPicker) {
            DocumentPicker(types: [.commaSeparatedText, .text, .data]) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        let dataManager = FileDataManager.shared
                        switch currentFileType {
                        case .targetFile:
                            targetFileName = url.lastPathComponent
                            targetFileURL = url
                            dataManager.targetFileURL = url
                        case .boostFile:
                            boostFileName = url.lastPathComponent
                            boostFileURL = url
                            dataManager.boostFileURL = url
                        case .allYearsFile:
                            allYearsFileName = url.lastPathComponent
                            allYearsFileURL = url
                            dataManager.allYearsFileURL = url
                        case .finalYearFile:
                            finalYearFileName = url.lastPathComponent
                            finalYearFileURL = url
                            dataManager.finalYearFileURL = url
                        case .targetYearFile:
                            targetYearFileName = url.lastPathComponent
                            targetYearFileURL = url
                            dataManager.targetYearFileURL = url
                        default:
                            break
                        }
                    }
                case .failure(let error):
                    errorMessage = "Failed to select file: \(error.localizedDescription)"
                    showErrorAlert = true
                }
            }
        }
    }

    private func uploadFilesForAnalysis() {
        guard let targetFileURL = targetFileURL,
              let boostFileURL = boostFileURL,
              let allYearsFileURL = allYearsFileURL,
              let finalYearFileURL = finalYearFileURL,
              let targetYearFileURL = targetYearFileURL else {
            errorMessage = "All files must be selected"
            showErrorAlert = true
            return
        }

        isUploading = true
        apiService.uploadFilesForAnalysis(
            targetFileURL: targetFileURL,
            boostFileURL: boostFileURL,
            allYearsFileURL: allYearsFileURL,
            finalYearFileURL: finalYearFileURL,
            targetYearFileURL: targetYearFileURL
        ) { result in
            DispatchQueue.main.async {
                isUploading = false
                switch result {
                case .success(let response):
                    // Cache for results view
                    FileDataManager.shared.latestAnalysisResponse = response
                    pickleFileName = response.modelFile
                    showAnalysisCompleted = true
                case .failure(let error):
                    errorMessage = "Analysis failed: \(error.localizedDescription)"
                    showErrorAlert = true
                }
            }
        }
    }

    private func formattedCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd"
        return formatter.string(from: Date())
    }

    private func fileUploadRow(fileName: String, description: String, iconName: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(color)
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
                    .foregroundColor(.blue)
                    .font(.title3)
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
        }
    }
}

struct AnalyzeDataView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { AnalyzeDataView() }
    }
}
