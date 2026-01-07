//
//  TrainModelView.swift
//  PYCS-FINAL-APP
//
//  Created by Gauri Kulkarni on 4/13/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct TrainModelView: View {
    @State private var showCustomDocumentPicker = false
    @State private var isTraining = false
    @State private var showSuccess = false
    @State private var trainingFileName: String? = "No file selected"
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.white, Color.green.opacity(0.1)]),
                             startPoint: .top,
                             endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Train New Model")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .padding(.horizontal)
                    
                    Text("Please upload a CSV file with your training data")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    // File Upload Section
                    VStack(spacing: 15) {
                        fileUploadRow(fileName: trainingFileName ?? "No file selected", description: "Training Dataset", iconName: "doc.text.fill", color: .green) {
                            showCustomDocumentPicker = true
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                
                    // Train Model Button
                    Button(action: {
                        isTraining = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            // After 3 seconds, show success popup
                            isTraining = false
                            showSuccess = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "brain")
                            Text("Train New Model")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                    .disabled(isTraining || trainingFileName == "No file selected")
                    .padding(.horizontal)
                
                    if isTraining {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .green))
                                .scaleEffect(1.5)
                            Text("Training Model...")
                                .foregroundColor(.green)
                            Spacer()
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
                
                // Success Popup
                if showSuccess {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showSuccess = false
                        }
                    
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("New Model Created!")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Your model has been successfully trained and is ready to use.")
                            .multilineTextAlignment(.center)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            showSuccess = false
                            // Reset the file name to allow another upload
                            trainingFileName = "No file selected"
                        }) {
                            Text("Continue")
                                .foregroundColor(.white)
                                .frame(width: 200)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    }
                    .padding(30)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding(30)
                    .transition(.scale)
                    .animation(.spring(), value: showSuccess)
                }
            }
            .navigationTitle("Train Model")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showCustomDocumentPicker) {
            DocumentPicker(types: [.commaSeparatedText, .text, .data]) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        print("Selected training file: \(url)")
                        trainingFileName = url.lastPathComponent
                    }
                case .failure(let error):
                    print("Document picker error: \(error)")
                }
            }
        }
    }
    
    // Helper function to create file upload row
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
                    .foregroundColor(.green)
                    .font(.title3)
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
        }
    }
}

// For Xcode previews
struct TrainModelView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TrainModelView()
        }
    }
}
