//
//  ApplicationSummaryCard.swift
//
//
//  Created by Deniz Gözcü on 05.01.26.
//

import SwiftUI
import FirebaseFirestore

struct ApplicationSummaryCard: View {
    let application: ApplicationSummary
    let studentID: String? // Optional: studentID to load student name
    @State private var loadedStudentName: String? = nil
    
    init(application: ApplicationSummary, studentID: String? = nil) {
        self.application = application
        self.studentID = studentID
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(loadedStudentName ?? application.studentName)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(application.position)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(application.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {

                Button("Review") {
                    // Handle review
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onAppear {
            if let studentID = studentID, loadedStudentName == nil {
                Task {
                    await loadStudentName(studentID: studentID)
                }
            }
        }
    }
    
    private func loadStudentName(studentID: String) async {
        do {
            let db = Firestore.firestore()
            let studentDoc = try await db.collection("students").document(studentID).getDocument()
            
            if let data = studentDoc.data(),
               let name = data["fullName"] as? String {
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
struct ApplicationSummary : Identifiable {
    var id: UUID = UUID()
    var studentName: String
    var position: String
    var timeAgo: String
}

