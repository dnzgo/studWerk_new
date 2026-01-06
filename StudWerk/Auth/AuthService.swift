//
//  AuthService.swift
//  StudWerk
//
//  Created for authentication management
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import Foundation
import Combine

@MainActor
class AuthService: ObservableObject {
    // Published properties for UI updates
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // For now, we'll use a simple in-memory store
    // Later we'll replace this with Firebase/database calls
    private var users: [String: User] = [:] // email -> User
    private var passwords: [String: String] = [:] // email -> hashed password
    
    init() {
        // Check if user is already logged in (for session persistence)
        // This will be implemented with Firebase later
        checkAuthState()
    }
    
    // MARK: - Authentication State
    
    private func checkAuthState() {
        // TODO: Check for stored session/token
        // For now, start with no authenticated user
        isAuthenticated = false
        currentUser = nil
    }
    
    // MARK: - Login
    
    func login(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        // Validate input
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in email and password."
            isLoading = false
            throw AuthError.invalidInput
        }
        
        // Validate email format
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address."
            isLoading = false
            throw AuthError.invalidEmail
        }
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Check if user exists
        guard let user = users[email.lowercased()] else {
            errorMessage = "Invalid email or password."
            isLoading = false
            throw AuthError.invalidCredentials
        }
        
        // Check password (in production, this would be hashed)
        guard passwords[email.lowercased()] == password else {
            errorMessage = "Invalid email or password."
            isLoading = false
            throw AuthError.invalidCredentials
        }
        
        // Success - set authenticated user
        currentUser = user
        isAuthenticated = true
        isLoading = false
    }
    
    // MARK: - Student Registration
    
    func registerStudent(
        email: String,
        password: String,
        fullName: String,
        phone: String,
        uniEmail: String,
        iban: String
    ) async throws {
        isLoading = true
        errorMessage = nil
        
        // Validate all fields
        guard !email.isEmpty, !password.isEmpty, !fullName.isEmpty,
              !phone.isEmpty, !uniEmail.isEmpty, !iban.isEmpty else {
            errorMessage = "Please fill in all required fields."
            isLoading = false
            throw AuthError.invalidInput
        }
        
        // Validate email format
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address."
            isLoading = false
            throw AuthError.invalidEmail
        }
        
        // Validate university email format
        guard isValidEmail(uniEmail) else {
            errorMessage = "Please enter a valid university email address."
            isLoading = false
            throw AuthError.invalidEmail
        }
        
        // Check if email already exists
        let emailKey = email.lowercased()
        guard users[emailKey] == nil else {
            errorMessage = "An account with this email already exists."
            isLoading = false
            throw AuthError.emailAlreadyExists
        }
        
        // Validate password strength (minimum 6 characters)
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long."
            isLoading = false
            throw AuthError.weakPassword
        }
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Create user ID (in production, this would come from Firebase)
        let userId = UUID().uuidString
        
        // Create user object
        let user = User(
            id: userId,
            name: fullName,
            email: email,
            userType: .student,
            phone: phone,
            createdAt: Date(),
            uniEmail: uniEmail,
            iban: iban
        )
        
        // Store user and password (in production, password would be hashed)
        users[emailKey] = user
        passwords[emailKey] = password // In production: hash this!
        
        // Set as current user
        currentUser = user
        isAuthenticated = true
        isLoading = false
    }
    
    // MARK: - Employer Registration
    
    func registerEmployer(
        email: String,
        password: String,
        companyName: String,
        phone: String,
        companyAddress: String
    ) async throws {
        isLoading = true
        errorMessage = nil
        
        // Validate all fields
        guard !email.isEmpty, !password.isEmpty, !companyName.isEmpty,
              !phone.isEmpty, !companyAddress.isEmpty else {
            errorMessage = "Please fill in all required fields."
            isLoading = false
            throw AuthError.invalidInput
        }
        
        // Validate email format
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address."
            isLoading = false
            throw AuthError.invalidEmail
        }
        
        // Check if email already exists
        let emailKey = email.lowercased()
        guard users[emailKey] == nil else {
            errorMessage = "An account with this email already exists."
            isLoading = false
            throw AuthError.emailAlreadyExists
        }
        
        // Validate password strength
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long."
            isLoading = false
            throw AuthError.weakPassword
        }
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Create user ID
        let userId = UUID().uuidString
        
        // Create user object
        let user = User(
            id: userId,
            name: companyName,
            email: email,
            userType: .employer,
            phone: phone,
            createdAt: Date(),
            companyName: companyName,
            companyAddress: companyAddress
        )
        
        // Store user and password
        users[emailKey] = user
        passwords[emailKey] = password // In production: hash this!
        
        // Set as current user
        currentUser = user
        isAuthenticated = true
        isLoading = false
    }
    
    // MARK: - Logout
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        errorMessage = nil
    }
    
    // MARK: - Helper Methods
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case invalidInput
    case invalidEmail
    case invalidCredentials
    case emailAlreadyExists
    case weakPassword
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Please fill in all required fields."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .invalidCredentials:
            return "Invalid email or password."
        case .emailAlreadyExists:
            return "An account with this email already exists."
        case .weakPassword:
            return "Password must be at least 6 characters long."
        case .networkError:
            return "Network error. Please try again."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}