//
//  EmployerManager.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import Foundation
import FirebaseFirestore

final class EmployerManager {
    static let shared = EmployerManager()
    private init() {}
    
    private let db = Firestore.firestore()
    private var employersRef: CollectionReference { db.collection("employers") }
    
    func updateEmployerProfile(
        employerID: String,
        name: String,
        phone: String,
        address: String
    ) async throws {
        let updateData: [String: Any] = [
            "name": name,
            "phone": phone,
            "address": address
        ]
        
        try await employersRef.document(employerID).updateData(updateData)
    }
    
    func updateVATID(employerID: String, vatID: String) async throws {
        try await employersRef.document(employerID).updateData([
            "vatID": vatID
        ])
    }
    
    func updatePushNotificationsEnabled(employerID: String, enabled: Bool) async throws {
        try await employersRef.document(employerID).updateData([
            "pushNotificationsEnabled": enabled
        ])
    }
    
    func fetchPushNotificationsEnabled(employerID: String) async throws -> Bool {
        let document = try await employersRef.document(employerID).getDocument()
        guard let data = document.data() else {
            return false // Default to false if not set
        }
        return data["pushNotificationsEnabled"] as? Bool ?? false
    }
}
