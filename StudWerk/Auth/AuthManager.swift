//
//  AuthManager.swift
//  studwerktest
//
//  Created by Emir Yalçınkaya on 6.01.2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AuthManager {
    static let shared = AuthManager()
    private init() {}

    private let db = Firestore.firestore()

    private var usersRef: CollectionReference { db.collection("users") }
    private var studentsRef: CollectionReference { db.collection("students") }
    private var employersRef: CollectionReference { db.collection("employers") }

    func login(email: String, password: String) async throws -> (uid: String, email: String, type: UserType) {

        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let uid = result.user.uid


        let snapshot = try await usersRef.document(uid).getDocument()

        guard
            let data = snapshot.data(),
            let rawType = data["userType"] as? String,
            let type = UserType(rawValue: rawType)
        else {
            throw NSError(domain: "AuthManager", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "User profile not found in Firestore."
            ])
        }

        let savedEmail = data["email"] as? String ?? email
        return (uid, savedEmail, type)
    }

    func registerStudent(
        fullName: String,
        email: String,
        phone: String,
        uniEmail: String,
        iban: String,
        password: String
    ) async throws -> (uid: String, email: String, type: UserType) {


        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = result.user.uid


        do {
            try await usersRef.document(uid).setData([
                "email": email,
                "userType": UserType.student.rawValue,
                "createdAt": FieldValue.serverTimestamp()
            ])
            
            try await studentsRef.document(uid).setData([
                "userID": uid,
                "name": fullName,
                "phone": phone,
                "uniEmail": uniEmail,
                "iban": iban,
                "createdAt": FieldValue.serverTimestamp()
            ])

        } catch {
            throw error
        }

        return (uid, email, .student)
    }

    func registerEmployer(
        companyName: String,
        email: String,
        phone: String,
        companyAddress: String,
        password: String
    ) async throws -> (uid: String, email: String, type: UserType) {


        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = result.user.uid


        do {
            try await usersRef.document(uid).setData([
                "email": email,
                "userType": UserType.employer.rawValue,
                "createdAt": FieldValue.serverTimestamp()
            ])

            try await employersRef.document(uid).setData([
                "userID": uid,
                "companyName": companyName,
                "phone": phone,
                "address": companyAddress,
                "createdAt": FieldValue.serverTimestamp()
            ])

        } catch {
            throw error
        }

        return (uid, email, .employer)
    }

    func logout() throws {
        try Auth.auth().signOut()
    }
}
