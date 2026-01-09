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
    
}
