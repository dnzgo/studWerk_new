//
//  StudentHomeView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI

struct StudentHomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var jobs: [Job] = []
    @State private var applications: [Application] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Find your next job opportunity")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    
                    // Quick Stats
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Completed..",
                            value: "\(completedJobsCount)",
                            color: .blue,
                            icon: "briefcase.fill"
                            
                        )
                        
                        StatCard(
                            title: "Applications",
                            value: "\(applicationsCount)",
                            color: .green,
                            icon: "doc.text.fill"
                        )
                        
                        StatCard(
                            title: "Earnings",
                            value: "€\(totalEarnings)",
                            color: .orange,
                            icon: "eurosign.circle.fill"
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Featured Jobs Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Featured Jobs")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if featuredJobs.isEmpty {
                            Text("No featured jobs available")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(featuredJobs.prefix(3), id: \.id) { job in
                                        FeaturedJobCard(job: job)
                                            .environmentObject(appState)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    // Nearby Jobs Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Nearby Jobs")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if nearbyJobs.isEmpty {
                            Text("No nearby jobs available")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(nearbyJobs.prefix(5), id: \.id) { job in
                                    JobCard(job: job)
                                        .environmentObject(appState)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("StudWerk")
        }
        .task {
            await loadData()
        }
        .refreshable {
            await loadData()
        }
        .alert("Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private var featuredJobs: [Job] {
        // Featured jobs are the most recent ones that the student hasn't applied to
        let appliedJobIDs = Set(applications.map { $0.jobID })
        return Array(jobs
            .filter { !appliedJobIDs.contains($0.id) }
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(3))
    }
    
    private var nearbyJobs: [Job] {
        // Return jobs that the student hasn't applied to, sorted by creation date
        let appliedJobIDs = Set(applications.map { $0.jobID })
        return jobs
            .filter { !appliedJobIDs.contains($0.id) }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    private var applicationsCount: Int {
        applications.filter { $0.applicationStatus == .pending }.count
    }
    
    private var completedJobsCount: Int {
        applications.filter { $0.applicationStatus == .completed }.count
    }
    
    private var totalEarnings: Int {
        // Calculate earnings from completed jobs only
        let completed = applications.filter { app in
            app.applicationStatus == .completed
        }
        
        return completed.reduce(0) { total, app in
            // Extract payment amount from string like "€150" or "150"
            let paymentString = app.jobPayment
            let numbers = paymentString.components(separatedBy: CharacterSet.decimalDigits.inverted)
                .compactMap { Int($0) }
            let amount = numbers.first ?? 0
            return total + amount
        }
    }
    
    private func loadData() async {
        await loadJobs()
        await loadApplications()
    }
    
    private func loadJobs() async {
        print("StudentHomeView: Loading jobs")
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let fetchedJobs = try await JobManager.shared.fetchJobs(status: "open")
            print("StudentHomeView: Fetched \(fetchedJobs.count) jobs")
            await MainActor.run {
                self.jobs = fetchedJobs
                isLoading = false
                errorMessage = nil
            }
        } catch {
            await MainActor.run {
                isLoading = false
                let errorDesc = error.localizedDescription
                errorMessage = "Failed to load jobs: \(errorDesc)"
                print("Error loading jobs: \(errorDesc)")
                print("Full error: \(error)")
            }
        }
    }
    
    private func loadApplications() async {
        guard let studentID = appState.uid else {
            return
        }
        
        do {
            let fetchedApplications = try await ApplicationManager.shared.fetchApplicationsByStudent(studentID: studentID)
            await MainActor.run {
                self.applications = fetchedApplications
            }
        } catch {
            print("Error loading applications: \(error.localizedDescription)")
        }
    }
}
#Preview {
    StudentHomeView()
}
