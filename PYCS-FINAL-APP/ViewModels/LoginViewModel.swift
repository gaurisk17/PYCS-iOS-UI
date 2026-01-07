//
//  LoginViewModel.swift
//  PYCS-FINAL-APP
//
//  Created by Gauri Kulkarni on 4/13/25.
//

import Foundation
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showAlert: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var logoAnimation: Bool = false
    
    func authenticateUser() {
        // Retrieve saved user data from UserDefaults
        let savedEmail = UserDefaults.standard.string(forKey: "email")
        let savedPassword = UserDefaults.standard.string(forKey: "password")
        
        // Validate email and password
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please enter both email and password."
            showAlert = true
        } else if email == savedEmail && password == savedPassword {
            // Successful login
            isLoggedIn = true
        } else {
            errorMessage = "Invalid email or password. Please try again."
            showAlert = true
        }
    }
}
