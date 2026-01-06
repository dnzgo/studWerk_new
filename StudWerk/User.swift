//
//  User.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String  // Changed from UUID to String (will use Firebase UID or custom ID)
    var name: String
    var email: String
    var userType: UserType
    var phone: String
    var createdAt: Date
    
    // Student-specific fields (optional, only populated for students)
    var uniEmail: String?
    var iban: String?
    var studentAddress: String?
    
    // Employer-specific fields (optional, only populated for employers)
    var companyName: String?
    var companyAddress: String?

    init(
        id: String,
        name: String,
        email: String,
        userType: UserType,
        phone: String,
        createdAt: Date = Date(),
        uniEmail: String? = nil,
        iban: String? = nil,
        studentAddress: String? = nil,
        companyName: String? = nil,
        companyAddress: String? = nil
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.userType = userType
        self.phone = phone
        self.createdAt = createdAt
        self.uniEmail = uniEmail
        self.iban = iban
        self.studentAddress = studentAddress
        self.companyName = companyName
        self.companyAddress = companyAddress
    }
}
