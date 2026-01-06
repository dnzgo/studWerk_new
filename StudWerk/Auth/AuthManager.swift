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
        print("➡️ LOGIN: signing in...")

        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let uid = result.user.uid

        print("✅ LOGIN: signed in uid =", uid)
        print("➡️ LOGIN: reading users/\(uid)")

        let snapshot = try await usersRef.document(uid).getDocument()

        guard
            let data = snapshot.data(),
            let rawType = data["userType"] as? String,
            let type = UserType(rawValue: rawType)
        else {
            print("🔥 LOGIN ERROR: user profile missing in Firestore")
            throw NSError(domain: "AuthManager", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "User profile not found in Firestore."
            ])
        }

        let savedEmail = data["email"] as? String ?? email
        print("✅ LOGIN: userType =", type.rawValue)
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

        print("➡️ STUDENT REGISTER: creating auth user... email =", email)

        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = result.user.uid

        print("✅ STUDENT REGISTER: auth user created uid =", uid)

        do {
            print("➡️ STUDENT REGISTER: writing users/\(uid)")
            try await usersRef.document(uid).setData([
                "email": email,
                "userType": UserType.student.rawValue,
                "createdAt": FieldValue.serverTimestamp()
            ])
            print("✅ STUDENT REGISTER: users written")

            print("➡️ STUDENT REGISTER: writing students/\(uid)")
            try await studentsRef.document(uid).setData([
                "userID": uid,
                "name": fullName,
                "phone": phone,
                "uniEmail": uniEmail,
                "iban": iban,
                "createdAt": FieldValue.serverTimestamp()
            ])
            print("✅ STUDENT REGISTER: students written")

        } catch {
            print("🔥 STUDENT REGISTER FIRESTORE ERROR:", error)
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

        print("➡️ EMPLOYER REGISTER: creating auth user... email =", email)

        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = result.user.uid

        print("✅ EMPLOYER REGISTER: auth user created uid =", uid)

        do {
            print("➡️ EMPLOYER REGISTER: writing users/\(uid)")
            try await usersRef.document(uid).setData([
                "email": email,
                "userType": UserType.employer.rawValue,
                "createdAt": FieldValue.serverTimestamp()
            ])
            print("✅ EMPLOYER REGISTER: users written")

            print("➡️ EMPLOYER REGISTER: writing employers/\(uid)")
            try await employersRef.document(uid).setData([
                "userID": uid,
                "companyName": companyName,
                "phone": phone,
                "address": companyAddress,
                "createdAt": FieldValue.serverTimestamp()
            ])
            print("✅ EMPLOYER REGISTER: employers written")

        } catch {
            print("🔥 EMPLOYER REGISTER FIRESTORE ERROR:", error)
            throw error
        }

        return (uid, email, .employer)
    }

    func logout() throws {
        try Auth.auth().signOut()
    }
}
