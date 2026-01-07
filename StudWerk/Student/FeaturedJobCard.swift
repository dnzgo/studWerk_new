//
//  FeaturedJobCard.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI

struct FeaturedJobCard: View {
    let job: Job
    @EnvironmentObject var appState: AppState
    @State private var hasApplied = false
    @State private var isCheckingApplication = false
    @State private var showingJobDetail = false
    @State private var companyName = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(companyName.isEmpty ? "Company" : companyName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
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
                
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Text(job.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(job.dateString)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if hasApplied {
                Button("Applied") {
                    // Already applied
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(Color.green)
                .cornerRadius(8)
                .disabled(true)
            } else {
                Button(action: {
                    showingJobDetail = true
                }) {
                    Text("Apply Now")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(Color.blue)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .frame(width: 280)
        .onAppear {
            Task {
                await checkApplicationStatus()
                await loadCompanyName()
            }
        }
        .sheet(isPresented: $showingJobDetail) {
            NavigationView {
                JobDetailView(job: job)
                    .environmentObject(appState)
            }
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
}

