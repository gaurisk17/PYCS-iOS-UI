//
//  DashboardView.swift
//  PYCS-FINAL-APP
//
//  Created by Gauri Kulkarni on 4/13/25.
//

import SwiftUI

struct DashboardView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToLogin = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Enhanced gradient background
                LinearGradient(gradient: Gradient(colors: [.white, Color.blue.opacity(0.15), Color.purple.opacity(0.1)]),
                             startPoint: .top,
                             endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 25) {
                    // App logo and title section
                    VStack(spacing: 12) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                            .padding(.bottom, 8)
                            
                        Text("Welcome to PYCS")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                        
                        Text("Predict Your CropS")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                            .padding(.bottom, 10)
                    }
                    .padding(.top, 40)
                    
                    // Card view with app description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Crop Yield Prediction")
                            .font(.headline)
                            .foregroundColor(.primary)
                            
                        Text("Use machine learning to analyze environmental data and accurately predict crop yields for better agricultural planning.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.9))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal, 25)
                    
                    Spacer()
                    
                    // Analyze Crop Data Button (Enhanced)
                    NavigationLink {
                        AnalyzeDataView()
                    } label: {
                        HStack(spacing: 15) {
                            Image(systemName: "waveform.path.ecg")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Analyze Crop Data")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text("View insights and trends")
                                    .font(.caption)
                                    .opacity(0.9)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .opacity(0.7)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.blue, .blue.opacity(0.7)]),
                                          startPoint: .leading,
                                          endPoint: .trailing)
                        )
                        .cornerRadius(16)
                        .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .padding(.horizontal, 25)
                    
                    // Test Prediction Button (Enhanced)
                    NavigationLink {
                        TestPredictionView()
                    } label: {
                        HStack(spacing: 15) {
                            Image(systemName: "chart.bar.doc.horizontal")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Test Prediction")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text("Get yield forecasts")
                                    .font(.caption)
                                    .opacity(0.9)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .opacity(0.7)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.purple, .purple.opacity(0.7)]),
                                          startPoint: .leading,
                                          endPoint: .trailing)
                        )
                        .cornerRadius(16)
                        .shadow(color: .purple.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .padding(.horizontal, 25)
                    
                    Spacer()
                    
                    // Logout Button (Enhanced)
                    Button(action: {
                        // Clear user credentials
                        UserDefaults.standard.removeObject(forKey: "email")
                        UserDefaults.standard.removeObject(forKey: "password")
                        UserDefaults.standard.removeObject(forKey: "fullName")
                        
                        // Set flag to navigate to login
                        navigateToLogin = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 16))
                            Text("Logout")
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.red.opacity(0.8), .red.opacity(0.6)]),
                                          startPoint: .leading,
                                          endPoint: .trailing)
                        )
                        .cornerRadius(14)
                        .shadow(color: .red.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
                    .navigationBarBackButtonHidden(true)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Show settings or help
                    }) {
                        Image(systemName: "gear")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
