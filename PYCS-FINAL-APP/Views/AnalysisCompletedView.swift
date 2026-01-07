import SwiftUI

struct AnalysisCompletedView: View {
    let pickleFileName: String
    @State private var navigateToResults = false
    @State private var navigateToDashboard = false
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [.white, Color.green.opacity(0.2)]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    // Success animation
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.1))
                            .frame(width: 160, height: 160)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                        
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 130, height: 130)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                            .shadow(color: .green.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .padding()
                    .onAppear {
                        isAnimating = true
                    }
                    
                    // Title section
                    VStack(spacing: 10) {
                        Text("Analysis Ready!")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Your model has been successfully analyzed")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Pickle file card
                    VStack {
                        Text("Model File Generated")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 5)
                        
                        HStack {
                            Image(systemName: "doc.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                                .padding(.trailing, 5)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(pickleFileName)
                                    .font(.system(size: 16, weight: .semibold))
                                    .lineLimit(1)
                                
                                Text(formatFileDate())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Action to copy filename to clipboard
                                UIPasteboard.general.string = pickleFileName
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(.blue)
                                    .padding(8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.secondarySystemBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // File details
                    HStack(spacing: 25) {
                        fileDetailItem(icon: "arrow.down.doc.fill", title: "Format", detail: "Pickle")
                        fileDetailItem(icon: "internaldrive.fill", title: "Size", detail: formatFileSize())
                        fileDetailItem(icon: "checkmark.shield.fill", title: "Status", detail: "Ready")
                    }
                    .padding(.top, 5)
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 15) {
                        Button(action: { navigateToResults = true }) {
                            HStack {
                                Image(systemName: "chart.bar.xaxis")
                                    .font(.system(size: 18))
                                Text("View Analysis Results")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                                               startPoint: .leading,
                                               endPoint: .trailing)
                            )
                            .cornerRadius(15)
                            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        
                        Button(action: { navigateToDashboard = true }) {
                            HStack {
                                Image(systemName: "house.fill")
                                    .font(.system(size: 16))
                                Text("Return to Dashboard")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.primary)
                            .padding(.vertical, 12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    
                    // Hidden navigation links
                    NavigationLink(destination: AnalysisResultsView().navigationBarBackButtonHidden(true), isActive: $navigateToResults) {
                        EmptyView()
                    }
                    NavigationLink(destination: DashboardView().navigationBarBackButtonHidden(true), isActive: $navigateToDashboard) {
                        EmptyView()
                    }
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:
                Button(action: { navigateToDashboard = true }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Dashboard")
                    }
                    .foregroundColor(.blue)
                }
            )
        }
    }
    
    // Helper view for file details
    private func fileDetailItem(icon: String, title: String, detail: String) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.green)
                .padding(.bottom, 5)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(detail)
                .font(.footnote)
                .fontWeight(.semibold)
        }
        .frame(minWidth: 80)
    }
    
    // Helper method to format date
    private func formatFileDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
    
    // Helper method to mock file size
    private func formatFileSize() -> String {
        // Mock file size calculation
        let size = Double.random(in: 1.5...5.5)
        return String(format: "%.1f MB", size)
    }
}

struct AnalysisCompletedView_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisCompletedView(pickleFileName: "crop_yield_model_v2.pickle")
    }
}
