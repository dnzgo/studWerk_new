//
//  EmployerApplicationCard.swift
//  StudWerk
//
//  Created by Deniz Gözcü on 07.01.26.
//

import SwiftUI
import Combine
import FirebaseFirestore

struct EmployerApplicationCard: View {
    let application: Application
    @State private var studentName = ""
    @State private var studentPhone = ""
    @State private var studentEmail = ""
    @State private var isLoadingStudent = false
    @State private var showingStudentContact = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(studentName.isEmpty ? "Loading..." : studentName)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(studentPhone.isEmpty ? "Loading..." : studentPhone)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ApplicationStatusBadge(status: application.applicationStatus)
            }
            
            HStack {
                Spacer()
                
                Image(systemName: "clock")
                    .foregroundColor(.orange)
                    .font(.caption)
                
                Text(application.appliedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "briefcase")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Text(application.position)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: "eurosign.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                
                Text(application.pay)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Button("Contact") {
                    showingStudentContact = true
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                
                Spacer()
                
                if application.applicationStatus == .pending {
                    HStack(spacing: 8) {
                        Button("Reject") {
                            Task {
                                await updateApplicationStatus(.rejected)
                            }
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        
                        Button("Accept") {
                            Task {
                                await updateApplicationStatus(.accepted)
                            }
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .cornerRadius(6)
                    }
                } else if application.applicationStatus == .accepted {
                    Button("Complete") {
                        Task {
                            await completeJob()
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(6)
                }
            }
            .sheet(isPresented: $showingStudentContact) {
                NavigationView {
                    StudentContactView(
                        studentName: studentName,
                        email: studentEmail,
                        phone: studentPhone
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onAppear {
            Task {
                await loadStudentName()
            }
        }
    }
    
    private func loadStudentName() async {
        guard !isLoadingStudent else { return }
        
        await MainActor.run {
            isLoadingStudent = true
        }
        
        do {
            let db = Firestore.firestore()
            
            // Load student info from students collection
            let studentDoc = try await db.collection("students").document(application.studentID).getDocument()
            
            if let data = studentDoc.data() {
                await MainActor.run {
                    if let name = data["name"] as? String {
                        studentName = name
                    }
                    if let phone = data["phone"] as? String {
                        studentPhone = phone
                    }
                }
            }
            
            // Load email from users collection
            let userDoc = try await db.collection("users").document(application.studentID).getDocument()
            
            if let userData = userDoc.data() {
                await MainActor.run {
                    if let email = userData["email"] as? String {
                        studentEmail = email
                    }
                    isLoadingStudent = false
                }
            } else {
                await MainActor.run {
                    isLoadingStudent = false
                }
            }
        } catch {
            await MainActor.run {
                isLoadingStudent = false
                print("Error loading student info: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateApplicationStatus(_ status: ApplicationStatus) async {
        do {
            try await ApplicationManager.shared.updateApplicationStatus(applicationID: application.id, status: status)
            print("Updated application \(application.id) to \(status.rawValue)")
            // Post notification to reload applications
            NotificationCenter.default.post(name: NSNotification.Name("ApplicationStatusUpdated"), object: nil)
        } catch {
            print("Error updating application status: \(error.localizedDescription)")
        }
    }
    
    private func completeJob() async {
        do {
            try await ApplicationManager.shared.completeJob(applicationID: application.id)
            print("Completed job for application \(application.id)")
            // Post notification to reload applications and jobs
            NotificationCenter.default.post(name: NSNotification.Name("ApplicationStatusUpdated"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("JobStatusUpdated"), object: nil)
        } catch {
            print("Error completing job: \(error.localizedDescription)")
        }
    }
}

struct ApplicationStatusBadge: View {
    let status: ApplicationStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(status.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.color.opacity(0.2))
            .cornerRadius(6)
    }
}
