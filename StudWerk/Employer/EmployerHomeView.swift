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
                    // header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing : 4) {
                                Text("Dashboard")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                            
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    
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
                                // handle navigation to applications
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 20)
                        
                        ScrollView(.vertical, showsIndicators: false) {
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
                                    ForEach(recentApplications, id: \.0.id) { applicationTuple in
                                        ApplicationSummaryCard(
                                            application: applicationTuple.0,
                                            studentID: applicationTuple.1
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
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
        applications.count
    }
    
    private var hiredStudentsCount: Int {
        applications.filter { $0.applicationStatus == .accepted || $0.applicationStatus == .completed }.count
    }
    
    private var recentApplications: [(ApplicationSummary, String)] {
        // Get the 5 most recent applications with their studentIDs
        let recent = applications
            .sorted { $0.appliedAt > $1.appliedAt }
            .prefix(5)
        
        return recent.map { app in
            (
                ApplicationSummary(
                    id: UUID(),
                    studentName: "Student", // Will be loaded asynchronously
                    position: app.position,
                    timeAgo: app.appliedDate
                ),
                app.studentID
            )
        }
    }
    
    private var totalSpend: String {
        let total = jobs
            .filter { $0.status == "completed" || $0.status == "closed" }
            .compactMap { Double($0.payment) }
            .reduce(0, +)
        
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
