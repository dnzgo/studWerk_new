//
//  UserManager.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 8.01.2026.
//

import Foundation
import FirebaseFirestore

final class UserManager {
    static let shared = UserManager()
    private init() {}
    
    private let db = Firestore.firestore()
    private var usersRef: CollectionReference { db.collection("users") }
    
    func updatePushNotificationsEnabled(userID: String, enabled: Bool) async throws {
        try await usersRef.document(userID).updateData([
            "pushNotificationsEnabled": enabled
        ])
    }
    
    func fetchPushNotificationsEnabled(userID: String) async throws -> Bool {
        let document = try await usersRef.document(userID).getDocument()
        guard let data = document.data() else {
            return false // Default to false if not set
        }
        return data["pushNotificationsEnabled"] as? Bool ?? false
    }
}
