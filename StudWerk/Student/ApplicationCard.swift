//
//  ApplicationCard.swift
//  StudWerk
//
//  Created by Deniz Gözcü on 07.01.26.
//

import SwiftUI

struct ApplicationCard: View {
    let application: Application
    @EnvironmentObject var appState: AppState
    @State private var companyName = ""
    @State private var isWithdrawing = false
    @State private var showingWithdrawAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var showingJobDetail = false
    @State private var job: Job? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(companyName.isEmpty ? "Company" : companyName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Text(application.position)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                StatusBadge(status: application.applicationStatus)
            }
            
            HStack {
                Image(systemName: "eurosign.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                
                Text(application.pay)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "calendar")
                    .foregroundColor(.orange)
                    .font(.caption)
                
                Text(application.appliedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if application.applicationStatus == .pending {
                HStack {
                    Button(action: withdrawApplication) {
                        if isWithdrawing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .red))
                        } else {
                            Text("Withdraw")
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                    .disabled(isWithdrawing)
                    
                    Spacer()
                    
                    Button("View Details") {
                        Task {
                            await loadJobAndShowDetail()
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
            } else if application.applicationStatus == .accepted {
                HStack {
                    Button("Contact Employer") {
                        // Handle contact
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button("View Contract") {
                        // Handle view contract
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                }
            } else {
                HStack {
                    Spacer()
                    
                    Button("View Details") {
                        Task {
                            await loadJobAndShowDetail()
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onAppear {
            Task {
                await loadCompanyName()
            }
        }
        .sheet(isPresented: $showingJobDetail) {
            if let job = job {
                NavigationView {
                    JobDetailView(job: job)
                        .environmentObject(appState)
                }
            }
        }
        .alert("Withdraw Application", isPresented: $showingWithdrawAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Withdraw", role: .destructive) {
                Task {
                    await performWithdraw()
                }
            }
        } message: {
            Text("Are you sure you want to withdraw this application?")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func loadCompanyName() async {
        do {
            if let name = try await JobManager.shared.fetchEmployerCompanyName(employerID: application.employerID) {
                await MainActor.run {
                    companyName = name
                }
            }
        } catch {
            print("Error loading company name: \(error.localizedDescription)")
        }
    }
    
    private func loadJobAndShowDetail() async {
        do {
            if let fetchedJob = try await JobManager.shared.fetchJob(byID: application.jobID) {
                await MainActor.run {
                    job = fetchedJob
                    showingJobDetail = true
                }
            } else {
                await MainActor.run {
                    errorMessage = "Job not found"
                    showingErrorAlert = true
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load job details: \(error.localizedDescription)"
                showingErrorAlert = true
            }
        }
    }
    
    private func withdrawApplication() {
        showingWithdrawAlert = true
    }
    
    private func performWithdraw() async {
        await MainActor.run {
            isWithdrawing = true
        }
        
        do {
            try await ApplicationManager.shared.withdrawApplication(applicationID: application.id)
            await MainActor.run {
                isWithdrawing = false
            }
            // Post notification to reload applications
            NotificationCenter.default.post(name: NSNotification.Name("ApplicationWithdrawn"), object: nil)
        } catch {
            await MainActor.run {
                isWithdrawing = false
                errorMessage = "Failed to withdraw application: \(error.localizedDescription)"
                showingErrorAlert = true
            }
        }
    }
}

struct StatusBadge: View {
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

struct JobApplication: Identifiable {
    let id = UUID()
    let company: String
    let position: String
    let pay: String
    let appliedDate: String
    let status: ApplicationStatus
}

enum ApplicationStatus: String, CaseIterable {
    case pending = "Pending"
    case accepted = "Accepted"
    case completed = "Completed"
    case rejected = "Rejected"
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .accepted: return .green
        case .completed: return .blue
        case .rejected: return .red
        }
    }
}
