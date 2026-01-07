//
//  JobDetailView.swift
//  StudWerk
//
//  Created on 07.01.26.
//

import SwiftUI

struct JobDetailView: View {
    let job: Job
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var hasApplied = false
    @State private var isCheckingApplication = true
    @State private var isApplying = false
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var companyName = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(companyName.isEmpty ? "Company" : companyName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text(job.position)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Category badge
                    Text(job.category)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
                
                Divider()
                
                // Job Details
                VStack(alignment: .leading, spacing: 16) {
                    // Payment
                    HStack {
                        Image(systemName: "eurosign.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Payment")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(job.pay)
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    // Date and Time
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.orange)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Date & Time")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(job.dateString)
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    // Location
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Location")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(job.location)
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                Divider()
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(job.description)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle("Job Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isCheckingApplication {
                    ProgressView()
                } else if hasApplied {
                    Button("Applied") {
                        // Already applied
                    }
                    .disabled(true)
                    .foregroundColor(.green)
                } else {
                    Button(action: applyToJob) {
                        if isApplying {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Apply")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(isApplying)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(isApplying ? Color.blue.opacity(0.6) : Color.blue)
                    .cornerRadius(8)
                }
            }
        }
        .task {
            await checkApplicationStatus()
            await loadCompanyName()
        }
        .alert("Success", isPresented: $showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your application has been submitted successfully!")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func checkApplicationStatus() async {
        guard let studentID = appState.uid else {
            await MainActor.run {
                isCheckingApplication = false
            }
            return
        }
        
        do {
            let applied = try await ApplicationManager.shared.hasAppliedToJob(jobID: job.id, studentID: studentID)
            await MainActor.run {
                hasApplied = applied
                isCheckingApplication = false
            }
        } catch {
            await MainActor.run {
                isCheckingApplication = false
                print("Error checking application status: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadCompanyName() async {
        do {
            if let name = try await JobManager.shared.fetchEmployerCompanyName(employerID: job.employerID) {
                await MainActor.run {
                    companyName = name
                }
            }
        } catch {
            print("Error loading company name: \(error.localizedDescription)")
        }
    }
    
    private func applyToJob() {
        guard let studentID = appState.uid else {
            errorMessage = "You must be logged in to apply"
            showingErrorAlert = true
            return
        }
        
        Task {
            await MainActor.run {
                isApplying = true
            }
            
            do {
                _ = try await ApplicationManager.shared.applyToJob(jobID: job.id, studentID: studentID)
                await MainActor.run {
                    hasApplied = true
                    isApplying = false
                    showingSuccessAlert = true
                }
            } catch {
                await MainActor.run {
                    isApplying = false
                    errorMessage = error.localizedDescription
                    showingErrorAlert = true
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        JobDetailView(job: Job(
            id: "1",
            employerID: "emp1",
            jobTitle: "Software Developer",
            jobDescription: "We are looking for a software developer...",
            payment: "150",
            date: Date(),
            startTime: Date(),
            endTime: Date(),
            category: "Technology",
            location: "Berlin",
            createdAt: Date(),
            status: "open"
        ))
        .environmentObject(AppState())
    }
}

