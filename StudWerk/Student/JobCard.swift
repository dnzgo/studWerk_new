//
//  JobCard.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI

struct JobCard: View {
    let job: Job
    @EnvironmentObject var appState: AppState
    @State private var hasApplied = false
    @State private var isCheckingApplication = false
    @State private var isApplying = false
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var showingJobDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.position)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Spacer()
            }
            
            HStack {
                Image(systemName: "eurosign.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                
                Text(job.pay)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "clock.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                
                Text(job.dateString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Text(job.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(job.distance)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Button("View Details") {
                    showingJobDetail = true
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                
                Spacer()
                
                if hasApplied {
                    Button("Applied") {
                        // Already applied
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .cornerRadius(6)
                    .disabled(true)
                } else {
                    Button(action: quickApply) {
                        if isApplying {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Quick Apply")
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(isApplying ? Color.blue.opacity(0.6) : Color.blue)
                    .cornerRadius(6)
                    .disabled(isApplying || isCheckingApplication)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onAppear {
            Task {
                await checkApplicationStatus()
            }
        }
        .sheet(isPresented: $showingJobDetail) {
            NavigationView {
                JobDetailView(job: job)
                    .environmentObject(appState)
            }
        }
        .alert("Success", isPresented: $showingSuccessAlert) {
            Button("OK") { }
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
            return
        }
        
        await MainActor.run {
            isCheckingApplication = true
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
    
    private func quickApply() {
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
