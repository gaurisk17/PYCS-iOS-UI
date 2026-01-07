//
//  LoginView.swift
//  PYCS-FINAL-APP
//
//  Created by Gauri Kulkarni on 4/13/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var showSignUp: Bool = false
    @State private var emailFieldIsFocused: Bool = false
    @State private var passwordFieldIsFocused: Bool = false
    
    var body: some View {
        NavigationView {
            if viewModel.isLoggedIn {
                DashboardView()
            } else if showSignUp {
                SignUpView(showSignUp: $showSignUp)
                    .transition(.move(edge: .trailing))
            } else {
                loginContent
                    .transition(.move(edge: .leading))
                    .navigationBarHidden(true)
            }
        }
        .animation(.easeInOut, value: showSignUp)
        .animation(.easeInOut, value: viewModel.isLoggedIn)
    }
    
    private var loginContent: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [.white, Color.green.opacity(0.2)]),
                          startPoint: .top,
                          endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            // Content
            ScrollView {
                VStack(spacing: 30) {
                    Spacer(minLength: 40)
                    
                    logoSection
                    
                    Spacer(minLength: 20)
                    
                    welcomeSection
                    
                    credentialsSection
                    
                    forgotPasswordButton
                    
                    loginButton
                    
                    divider
                    
                    signUpButton
                    
                    Spacer(minLength: 30)
                    
                    footerSection
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Login Error"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private var logoSection: some View {
        VStack {
            Image("pycs_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .shadow(color: .gray.opacity(0.5), radius: 5)
                .scaleEffect(viewModel.logoAnimation ? 1.1 : 1.0)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        viewModel.logoAnimation = true
                    }
                }
            
            Text("PYCS")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.green)
            
            Text("(Predict Your CropS)")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.green.opacity(0.8))
        }
    }
    
    private var welcomeSection: some View {
        VStack(spacing: 10) {
            Text("Welcome Back")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Log in to continue to your account")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var credentialsSection: some View {
        VStack(spacing: 20) {
            // Email Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(emailFieldIsFocused ? .green : .gray)
                        .padding(.leading, 8)
                    
                    TextField("", text: $viewModel.email)
                        .placeholder(when: viewModel.email.isEmpty) {
                            Text("Enter your email").foregroundColor(.gray.opacity(0.8))
                        }
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                        .onTapGesture {
                            emailFieldIsFocused = true
                            passwordFieldIsFocused = false
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
                    
                    SecureField("", text: $viewModel.password)
                        .placeholder(when: viewModel.password.isEmpty) {
                            Text("Enter your password").foregroundColor(.gray.opacity(0.8))
                        }
                        .onTapGesture {
                            emailFieldIsFocused = false
                            passwordFieldIsFocused = true
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
        }
    }
    
    private var forgotPasswordButton: some View {
        HStack {
            Spacer()
            
            Button(action: {
                // Handle forgot password
            }) {
                Text("Forgot Password?")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.top, -10)
    }
    
    private var loginButton: some View {
        Button(action: {
            withAnimation {
                viewModel.authenticateUser()
            }
        }) {
            HStack {
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
                
                Text("Login")
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
        .padding(.top, 20)
    }
    
    private var divider: some View {
        HStack {
            VStack {
                Divider()
            }
            
            Text("OR")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 10)
            
            VStack {
                Divider()
            }
        }
        .padding(.vertical, 20)
    }
    
    private var signUpButton: some View {
        Button(action: {
            withAnimation {
                showSignUp = true
            }
        }) {
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.secondary)
                
                Text("Sign Up")
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            .font(.system(size: 16))
        }
    }
    
    private var footerSection: some View {
        Text("© 2025 PYCS Analytics, Inc. All rights reserved.")
            .font(.caption2)
            .foregroundColor(.gray)
            .padding(.top, 20)
    }
}

// Custom View Extension for Placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
