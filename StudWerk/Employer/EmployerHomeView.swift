//
//  EmployerHomeView.swift
//  StudWerk
//
//  Created by Deniz Gözcü on 5.01.2026.
//

import SwiftUI

struct EmployerHomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var jobs: [Job] = []
    @State private var applications: [Application] = []
    @State private var isLoading = false
    
    var body : some View {
        NavigationView {
            ScrollView {
                VStack (spacing : 24) {
                    // statistic cards
                    VStack(spacing : 16) {
                        HStack(spacing : 16) {
                            StatCard(
                                title: "Active Jobs",
                                value: "\(activeJobsCount)",
                                color: .blue,
                                icon: "briefcase.fill")
                            
                            StatCard(
                                title: "Applications",
                                value: "\(applicationsCount)",
                                color: .green,
                                icon: "doc.text.fill")
                        }
                        HStack(spacing : 16) {
                            StatCard(
                                title: "Hired Students",
                                value: "\(hiredStudentsCount)",
                                color: .orange,
                                icon: "person.2.fill")
                            
                            StatCard(
                                title: "Total Spend",
                                value: "€\(totalSpend)",
                                color: .purple,
                                icon: "eurosign.circle.fill")
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // recent applications
                    VStack(alignment : .leading, spacing : 16) {
                        HStack {
                            Text("Recent Applications")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Button("View All") {
                                // Navigate to My Jobs tab and switch to Applications
                                NotificationCenter.default.post(
                                    name: NSNotification.Name("NavigateToApplications"),
                                    object: nil
                                )
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            if recentApplications.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 50))
                                        .foregroundColor(.secondary)
                                    Text("No recent applications")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    Text("Applications will appear here when students apply to your jobs")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.top, 40)
                            } else {
                                ForEach(recentApplications, id: \.id) { application in
                                    ApplicationSummaryCard(application: application)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await loadData()
        }
        .refreshable {
            await loadData()
        }
    }
    
    private var activeJobsCount: Int {
        jobs.filter { $0.status == "open" || $0.status == "active" }.count
    }
    
    private var applicationsCount: Int {
        applications.filter { $0.applicationStatus == .pending }.count
    }
    
    private var hiredStudentsCount: Int {
        applications.filter { $0.applicationStatus == .accepted || $0.applicationStatus == .completed }.count
    }
    
    private var recentApplications: [Application] {
        // Get the 5 most recent applications
        return Array(applications
            .sorted { $0.appliedAt > $1.appliedAt }
            .prefix(5))
    }
    
    private var totalSpend: String {
        // Calculate total spend from completed applications only
        let completed = applications.filter { app in
            app.applicationStatus == .completed
        }
        
        let total = completed.reduce(0) { total, app in
            // Extract payment amount from string like "€150" or "150"
            let paymentString = app.jobPayment
            let numbers = paymentString.components(separatedBy: CharacterSet.decimalDigits.inverted)
                .compactMap { Double($0) }
            let amount = numbers.first ?? 0
            return total + amount
        }
        
        if total >= 1000 {
            return String(format: "%.1fK", total / 1000)
        } else {
            return String(format: "%.0f", total)
        }
    }
    
    private func loadData() async {
        await loadJobs()
        await loadApplications()
    }
    
    private func loadJobs() async {
        guard let employerID = appState.uid else {
            return
        }
        
        isLoading = true
        
        do {
            let fetchedJobs = try await JobManager.shared.fetchJobsByEmployer(employerID: employerID)
            await MainActor.run {
                self.jobs = fetchedJobs
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                print("Error loading jobs: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadApplications() async {
        guard let employerID = appState.uid else {
            return
        }
        
        do {
            let fetchedApplications = try await ApplicationManager.shared.fetchApplicationsByEmployer(employerID: employerID)
            await MainActor.run {
                self.applications = fetchedApplications
            }
        } catch {
            print("Error loading applications: \(error.localizedDescription)")
        }
    }
}

#Preview {
    EmployerHomeView()
        .environmentObject(AppState())
}
