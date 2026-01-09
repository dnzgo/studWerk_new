//
//  StudentManager.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 8.01.2026.
//

import Foundation
import FirebaseFirestore

final class StudentManager {
    static let shared = StudentManager()
    private init() {}
    
    private let db = Firestore.firestore()
    private var studentsRef: CollectionReference { db.collection("students") }
    
    func updateStudentProfile(
        studentID: String,
        name: String,
        phone: String,
        address: String,
        iban: String
    ) async throws {
        let updateData: [String: Any] = [
            "name": name,
            "phone": phone,
            "address": address,
            "iban": iban
        ]
        
        try await studentsRef.document(studentID).updateData(updateData)
    }
    
}
