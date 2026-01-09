//
//  InputValidator.swift
//  StudWerk
//
//  Created on 07.01.26.
//

import Foundation

struct InputValidator {
    
    // MARK: - Email Validation
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    static func validateEmail(_ email: String) -> ValidationResult {
        if email.isEmpty {
            return .failure("Email is required")
        }
        if !isValidEmail(email) {
            return .failure("Please enter a valid email address")
        }
        return .success
    }
    
    // MARK: - Phone Validation
    static func isValidPhone(_ phone: String) -> Bool {
        // Remove spaces, dashes, and parentheses
        let cleaned = phone.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "+", with: "")
        
        // Check if it contains only digits and has reasonable length (7-15 digits)
        let digitsOnly = cleaned.allSatisfy { $0.isNumber }
        return digitsOnly && cleaned.count >= 7 && cleaned.count <= 15
    }
    
    static func validatePhone(_ phone: String) -> ValidationResult {
        if phone.isEmpty {
            return .failure("Phone number is required")
        }
        if !isValidPhone(phone) {
            return .failure("Please enter a valid phone number (7-15 digits)")
        }
        return .success
    }
    
    // MARK: - IBAN Validation
    static func isValidIBAN(_ iban: String) -> Bool {
        // Remove spaces and convert to uppercase
        let cleaned = iban.replacingOccurrences(of: " ", with: "").uppercased()
        
        // Basic IBAN format check: starts with 2 letters (country code), followed by 2 digits, then alphanumeric
        if cleaned.count < 15 || cleaned.count > 34 {
            return false
        }
        
        // Check country code (first 2 characters are letters)
        let countryCode = String(cleaned.prefix(2))
        guard countryCode.allSatisfy({ $0.isLetter }) else {
            return false
        }
        
        // Check check digits (next 2 characters are digits)
        let checkDigits = String(cleaned.dropFirst(2).prefix(2))
        guard checkDigits.allSatisfy({ $0.isNumber }) else {
            return false
        }
        
        // Rest should be alphanumeric
        let rest = String(cleaned.dropFirst(4))
        return rest.allSatisfy { $0.isLetter || $0.isNumber }
    }
    
    static func validateIBAN(_ iban: String) -> ValidationResult {
        if iban.isEmpty {
            return .failure("IBAN is required")
        }
        if !isValidIBAN(iban) {
            return .failure("Please enter a valid IBAN (e.g., DE89 3704 0044 0532 0130 00)")
        }
        return .success
    }
    
    // MARK: - Password Validation
    static func isValidPassword(_ password: String) -> Bool {
        // At least 8 characters, contains at least one letter and one number
        return password.count >= 8 &&
               password.range(of: "[A-Za-z]", options: .regularExpression) != nil &&
               password.range(of: "[0-9]", options: .regularExpression) != nil
    }
    
    static func validatePassword(_ password: String) -> ValidationResult {
        if password.isEmpty {
            return .failure("Password is required")
        }
        if password.count < 8 {
            return .failure("Password must be at least 8 characters long")
        }
        if !isValidPassword(password) {
            return .failure("Password must contain at least one letter and one number")
        }
        return .success
    }
    
    static func validatePasswordConfirmation(_ password: String, _ confirmation: String) -> ValidationResult {
        if confirmation.isEmpty {
            return .failure("Please confirm your password")
        }
        if password != confirmation {
            return .failure("Passwords do not match")
        }
        return .success
    }
    
    // MARK: - Name Validation
    static func isValidName(_ name: String) -> Bool {
        // At least 2 characters, contains only letters, spaces, hyphens, and apostrophes
        let cleaned = name.trimmingCharacters(in: .whitespaces)
        if cleaned.count < 2 {
            return false
        }
        let nameRegex = "^[a-zA-ZÀ-ÿ\\s'-]+$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return namePredicate.evaluate(with: cleaned)
    }
    
    static func validateName(_ name: String) -> ValidationResult {
        if name.isEmpty {
            return .failure("Name is required")
        }
        if !isValidName(name) {
            return .failure("Please enter a valid name (at least 2 characters, letters only)")
        }
        return .success
    }
    
    // MARK: - Address Validation
    static func isValidAddress(_ address: String) -> Bool {
        // At least 5 characters (basic check)
        return address.trimmingCharacters(in: .whitespaces).count >= 5
    }
    
    static func validateAddress(_ address: String) -> ValidationResult {
        if address.isEmpty {
            return .failure("Address is required")
        }
        if !isValidAddress(address) {
            return .failure("Please enter a valid address (at least 5 characters)")
        }
        return .success
    }
}

enum ValidationResult {
    case success
    case failure(String)
    
    var isValid: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
    
    var errorMessage: String? {
        switch self {
        case .success: return nil
        case .failure(let message): return message
        }
    }
}
