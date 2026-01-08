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
    var phone: String
    var userType: UserType
    var createdAt: Date
    
    // Student-specific fields (optional, only populated for students)
    var iban: String?
    var studentAddress: String?
    
    // Employer-specific fields (optional, only populated for employers)
    var companyAddress: String?
    var vatID: String?

    init(
        id: String,
        name: String,
        email: String,
        userType: UserType,
        phone: String,
        createdAt: Date = Date(),
        iban: String? = nil,
        studentAddress: String? = nil,
        vatID: String? = nil,
        companyAddress: String? = nil
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.userType = userType
        self.phone = phone
        self.createdAt = createdAt
        self.iban = iban
        self.vatID = vatID
        self.studentAddress = studentAddress
        self.companyAddress = companyAddress
    }
}
