//
//  SignUpView.swift
//  PYCS-FINAL-APP
//
//  Created by Gauri Kulkarni on 4/13/25.
//

import SwiftUI

struct SignUpView: View {
    @Binding var showSignUp: Bool
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var fullName: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isSigningUp: Bool = false
    
    // Focus states for fields
    @State private var nameFieldIsFocused: Bool = false
    @State private var emailFieldIsFocused: Bool = false
    @State private var passwordFieldIsFocused: Bool = false
    @State private var confirmPasswordFieldIsFocused: Bool = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [.white, Color.green.opacity(0.2)]),
                          startPoint: .top,
                          endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            // Content
            ScrollView {
                VStack(spacing: 25) {
                    headerSection
                    
                    formFields
                    
                    signUpButton
                    
                    loginButton
                    
                    Spacer(minLength: 40)
                    
                    footerSection
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 40)
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Sign Up"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            // Logo
            Image("pycs_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .shadow(color: .gray.opacity(0.5), radius: 5)
            
            // Title and subtitle
            Text("Create Account")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("Join PYCS to predict and manage your crops")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 10)
    }
    
    private var formFields: some View {
        VStack(spacing: 20) {
            // Full Name Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Full Name")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(nameFieldIsFocused ? .green : .gray)
                        .padding(.leading, 8)
                    
                    TextField("", text: $fullName)
                        .placeholder(when: fullName.isEmpty) {
                            Text("Enter your full name").foregroundColor(.gray.opacity(0.8))
                        }
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                        .onTapGesture {
                            nameFieldIsFocused = true
                            emailFieldIsFocused = false
                            passwordFieldIsFocused = false
                            confirmPasswordFieldIsFocused = false
                        }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(nameFieldIsFocused ? Color.green : Color.clear, lineWidth: 2)
                )
                .animation(.easeInOut(duration: 0.2), value: nameFieldIsFocused)
            }
            
            // Email Field - Fixed capitalization issue
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(emailFieldIsFocused ? .green : .gray)
                        .padding(.leading, 8)
                    
                    TextField("", text: $email)
                        .placeholder(when: email.isEmpty) {
                            Text("Enter your email").foregroundColor(.gray.opacity(0.8))
                        }
                        .autocapitalization(.none) // This fixes the capitalization issue
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                        .onTapGesture {
                            nameFieldIsFocused = false
                            emailFieldIsFocused = true
                            passwordFieldIsFocused = false
                            confirmPasswordFieldIsFocused = false
                        }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(emailFieldIsFocused ? Color.green : Color.clear, lineWidth: 2)
                )
                .animation(.easeInOut(duration: 0.2), value: emailFieldIsFocused)
            }
            
            // Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(passwordFieldIsFocused ? .green : .gray)
                        .padding(.leading, 8)
                    
                    SecureField("", text: $password)
                        .placeholder(when: password.isEmpty) {
                            Text("Create a password").foregroundColor(.gray.opacity(0.8))
                        }
                        .onTapGesture {
                            nameFieldIsFocused = false
                            emailFieldIsFocused = false
                            passwordFieldIsFocused = true
                            confirmPasswordFieldIsFocused = false
                        }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(passwordFieldIsFocused ? Color.green : Color.clear, lineWidth: 2)
                )
                .animation(.easeInOut(duration: 0.2), value: passwordFieldIsFocused)
            }
            
            // Confirm Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(confirmPasswordFieldIsFocused ? .green : .gray)
                        .padding(.leading, 8)
                    
                    SecureField("", text: $confirmPassword)
                        .placeholder(when: confirmPassword.isEmpty) {
                            Text("Confirm your password").foregroundColor(.gray.opacity(0.8))
                        }
                        .onTapGesture {
                            nameFieldIsFocused = false
                            emailFieldIsFocused = false
                            passwordFieldIsFocused = false
                            confirmPasswordFieldIsFocused = true
                        }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(confirmPasswordFieldIsFocused ? Color.green : Color.clear, lineWidth: 2)
                )
                .animation(.easeInOut(duration: 0.2), value: confirmPasswordFieldIsFocused)
            }
            
            // Password requirements
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Text("Password must be at least 8 characters")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.top, -10)
        }
    }
    
    private var signUpButton: some View {
        Button(action: {
            withAnimation {
                isSigningUp = true
                signUp()
            }
        }) {
            HStack {
                if isSigningUp {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.trailing, 5)
                } else {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                }
                
                Text("Create Account")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(15)
            .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .padding(.top, 10)
        .disabled(isSigningUp)
    }
    
    private var loginButton: some View {
        Button(action: {
            withAnimation {
                showSignUp = false
            }
        }) {
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.secondary)
                
                Text("Login")
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            .font(.system(size: 16))
        }
        .padding(.top, 10)
    }
    
    private var footerSection: some View {
        VStack(spacing: 15) {
            Text("By signing up, you agree to PYCS's")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 5) {
                Button(action: {}) {
                    Text("Terms of Service")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .underline()
                }
                
                Text("and")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button(action: {}) {
                    Text("Privacy Policy")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .underline()
                }
            }
            
            Text("© 2025 PYCS Analytics, Inc.")
                .font(.caption2)
                .foregroundColor(.gray)
                .padding(.top, 10)
        }
    }
    
    func signUp() {
        // Validate inputs
        guard !fullName.isEmpty, !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in all fields"
            showAlert = true
            isSigningUp = false
            return
        }
        
        guard isValidEmail(email) else {
            alertMessage = "Please enter a valid email address"
            showAlert = true
            isSigningUp = false
            return
        }
        
        guard password.count >= 8 else {
            alertMessage = "Password must be at least 8 characters long"
            showAlert = true
            isSigningUp = false
            return
        }
        
        guard password == confirmPassword else {
            alertMessage = "Passwords do not match"
            showAlert = true
            isSigningUp = false
            return
        }
        
        // Save user data
        UserDefaults.standard.set(fullName, forKey: "fullName")
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set(password, forKey: "password")
        
        // Show success message
        alertMessage = "Account created successfully!"
        showAlert = true
        
        // Dismiss sign up view after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSigningUp = false
            showSignUp = false
        }
    }
    
    // Email validation function
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(showSignUp: .constant(true))
    }
}
