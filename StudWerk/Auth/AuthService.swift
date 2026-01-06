//
//  AuthService.swift
//  StudWerk
//
//  Created for authentication management
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class AuthService: ObservableObject {
    // Published properties for UI updates
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    init() {
        // Listen to authentication state changes
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor in
                if let firebaseUser = firebaseUser {
                    await self?.fetchUserData(uid: firebaseUser.uid)
                } else {
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
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
        
        do {
            // Sign in with Firebase
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            // Fetch user data - this will automatically update isAuthenticated via the listener
            await fetchUserData(uid: result.user.uid)
        } catch {
            // Handle Firebase errors
            if let error = error as NSError? {
                switch error.code {
                case AuthErrorCode.wrongPassword.rawValue,
                     AuthErrorCode.userNotFound.rawValue,
                     AuthErrorCode.invalidEmail.rawValue:
                    errorMessage = "Invalid email or password."
                case AuthErrorCode.networkError.rawValue:
                    errorMessage = "Network error. Please check your connection."
                case AuthErrorCode.tooManyRequests.rawValue:
                    errorMessage = "Too many failed attempts. Please try again later."
                default:
                    errorMessage = error.localizedDescription
                }
            } else {
                errorMessage = "Login failed. Please try again."
            }
            isLoading = false
            throw AuthError.invalidCredentials
        }
        
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
        
        // Validate password strength
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long."
            isLoading = false
            throw AuthError.weakPassword
        }
        
        do {
            // Create Firebase Auth user
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let userId = result.user.uid
            
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
            
            // Save user to Firestore
            try db.collection("users").document(userId).setData(from: user)
            
            // Also save student-specific profile
            let studentProfile: [String: Any] = [
                "userId": userId,
                "fullName": fullName,
                "email": email,
                "phone": phone,
                "uniEmail": uniEmail,
                "iban": iban,
                "createdAt": Timestamp(date: Date())
            ]
            
            try await db.collection("students").document(userId).setData(studentProfile)
            
            // Set current user (fetchUserData will be called by the auth state listener)
            currentUser = user
            isAuthenticated = true
            
        } catch {
            // Handle Firebase errors
            if let error = error as NSError? {
                switch error.code {
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    errorMessage = "An account with this email already exists."
                case AuthErrorCode.weakPassword.rawValue:
                    errorMessage = "Password is too weak. Please choose a stronger password."
                case AuthErrorCode.invalidEmail.rawValue:
                    errorMessage = "Please enter a valid email address."
                case AuthErrorCode.networkError.rawValue:
                    errorMessage = "Network error. Please check your connection."
                default:
                    errorMessage = error.localizedDescription
                }
            } else {
                errorMessage = "Registration failed. Please try again."
            }
            isLoading = false
            throw AuthError.unknown
        }
        
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
        
        // Validate password strength
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long."
            isLoading = false
            throw AuthError.weakPassword
        }
        
        do {
            // Create Firebase Auth user
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let userId = result.user.uid
            
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
            
            // Save user to Firestore
            try db.collection("users").document(userId).setData(from: user)
            
            // Also save employer-specific profile
            let employerProfile: [String: Any] = [
                "userId": userId,
                "companyName": companyName,
                "email": email,
                "phone": phone,
                "companyAddress": companyAddress,
                "createdAt": Timestamp(date: Date())
            ]
            
            try await db.collection("employers").document(userId).setData(employerProfile)
            
            // Set current user
            currentUser = user
            isAuthenticated = true
            
        } catch {
            // Handle Firebase errors
            if let error = error as NSError? {
                switch error.code {
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    errorMessage = "An account with this email already exists."
                case AuthErrorCode.weakPassword.rawValue:
                    errorMessage = "Password is too weak. Please choose a stronger password."
                case AuthErrorCode.invalidEmail.rawValue:
                    errorMessage = "Please enter a valid email address."
                case AuthErrorCode.networkError.rawValue:
                    errorMessage = "Network error. Please check your connection."
                default:
                    errorMessage = error.localizedDescription
                }
            } else {
                errorMessage = "Registration failed. Please try again."
            }
            isLoading = false
            throw AuthError.unknown
        }
        
        isLoading = false
    }
    
    // MARK: - Fetch User Data
    
    private func fetchUserData(uid: String) async {
        do {
            let document = try await db.collection("users").document(uid).getDocument()
            
            if document.exists {
                let user = try document.data(as: User.self)
                currentUser = user
                isAuthenticated = true
            } else {
                // User document doesn't exist - might be a new user
                // This shouldn't happen, but handle gracefully
                currentUser = nil
                isAuthenticated = false
            }
        } catch {
            print("Error fetching user data: \(error.localizedDescription)")
            currentUser = nil
            isAuthenticated = false
        }
    }
    
    // MARK: - Logout
    
    func logout() throws {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            isAuthenticated = false
            errorMessage = nil
        } catch {
            throw AuthError.unknown
        }
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