//
//  ApplicationSummaryCard.swift
//
//
//  Created by Deniz Gözcü on 05.01.26.
//

import SwiftUI
import FirebaseFirestore

struct ApplicationSummaryCard: View {
    let application: Application
    @State private var loadedStudentName: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(loadedStudentName ?? "Loading...")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(application.position)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(application.appliedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onAppear {
            if loadedStudentName == nil {
                Task {
                    await loadStudentName(studentID: application.studentID)
                }
            }
        }
    }
    
    private func loadStudentName(studentID: String) async {
        do {
            let db = Firestore.firestore()
            let studentDoc = try await db.collection("students").document(studentID).getDocument()
            
            if let data = studentDoc.data(),
               let name = data["name"] as? String {
                await MainActor.run {
                    loadedStudentName = name
                }
            } else {
                // Try users collection as fallback
                let userDoc = try await db.collection("users").document(studentID).getDocument()
                if let data = userDoc.data(),
                   let name = data["name"] as? String {
                    await MainActor.run {
                        loadedStudentName = name
                    }
                }
            }
        } catch {
            print("Error loading student name: \(error.localizedDescription)")
        }
    }
}

