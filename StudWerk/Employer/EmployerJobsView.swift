//
//  EmployerSearchView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI
import Combine
import FirebaseFirestore

struct EmployerJobsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var jobs: [Job] = []
    @State private var applications: [Application] = []
    @State private var applicationCounts: [String: Int] = [:] // jobID -> count
    @State private var isLoading = false
    @State private var isLoadingApplications = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("Status", selection: $selectedTab) {
                    Text("Active").tag(0)
                    Text("Applications").tag(1)
                    Text("Completed").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToApplications"))) { _ in
                    // Switch to Applications tab
                    selectedTab = 1
                }
                
                // Content
                ScrollView {
                    if isLoading {
                        ProgressView()
                            .padding(.top, 40)
                    } else {
                        LazyVStack(spacing: 12) {
                            if selectedTab == 0 {
                                if activeJobsList.isEmpty {
                                    VStack(spacing: 16) {
                                        Image(systemName: "briefcase")
                                            .font(.system(size: 50))
                                            .foregroundColor(.secondary)
                                        Text("No active jobs")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        Text("Create a new job to get started")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.top, 40)
                                } else {
                                    ForEach(activeJobsList, id: \.id) { employerJob in
                                        EmployerJobCard(
                                            job: employerJob,
                                            originalJob: jobs.first { $0.id == employerJob.id }
                                        )
                                    }
                                }
                            } else if selectedTab == 1 {
                                // Applications tab
                                if isLoadingApplications {
                                    ProgressView()
                                        .padding(.top, 40)
                                } else if applications.isEmpty {
                                    VStack(spacing: 16) {
                                        Image(systemName: "doc.text")
                                            .font(.system(size: 50))
                                            .foregroundColor(.secondary)
                                        Text("No applications yet")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        Text("Applications will appear here when students apply to your jobs")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(.top, 40)
                                } else {
                                    ForEach(applications, id: \.id) { application in
                                        EmployerApplicationCard(application: application)
                                    }
                                }
                            } else {
                                if completedJobsList.isEmpty {
                                    VStack(spacing: 16) {
                                        Image(systemName: "checkmark.circle")
                                            .font(.system(size: 50))
                                            .foregroundColor(.secondary)
                                        Text("No completed jobs")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.top, 40)
                                } else {
                                    ForEach(completedJobsList, id: \.id) { employerJob in
                                        EmployerJobCard(
                                            job: employerJob,
                                            originalJob: jobs.first { $0.id == employerJob.id }
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
            }
            .navigationTitle("My Jobs")
        }
        .task {
            await loadJobs()
            await loadApplications()
        }
        .refreshable {
            await loadJobs()
            await loadApplications()
        }
        .onChange(of: selectedTab) { newValue in
            if newValue == 1 {
                Task {
                    await loadApplications()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ApplicationStatusUpdated"))) { _ in
            Task {
                await loadApplications()
                await refreshApplicationCounts()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("JobStatusUpdated"))) { _ in
            Task {
                await loadJobs()
                await loadApplications()
            }
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
    
    private var activeJobsList: [EmployerJob] {
        jobs.filter { job in
            job.status == "open" || job.status == "active"
        }
        .map { job in
            convertToEmployerJob(job)
        }
    }
    
    private var completedJobsList: [EmployerJob] {
        jobs.filter { job in
            job.status == "completed" || job.status == "closed"
        }
        .map { job in
            convertToEmployerJob(job)
        }
    }
    
    private func convertToEmployerJob(_ job: Job) -> EmployerJob {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let status: JobStatus
        switch job.status.lowercased() {
        case "open", "active":
            status = .active
        case "paused":
            status = .paused
        case "completed", "closed":
            status = .completed
        case "expired":
            status = .expired
        default:
            status = .active
        }
        
        let appCount = applicationCounts[job.id] ?? 0
        
        return EmployerJob(
            id: job.id,
            position: job.jobTitle,
            category: job.category,
            pay: job.pay,
            date: dateFormatter.string(from: job.date),
            location: job.location,
            applications: appCount,
            description: job.jobDescription,
            status: status
        )
    }
    
    private func loadJobs() async {
        guard let employerID = appState.uid else {
            print("⚠️ EmployerJobsView: No employerID found in appState")
            await MainActor.run {
                errorMessage = "No employer ID found. Please log in again."
            }
            return
        }
        
        print("🔍 EmployerJobsView: Loading jobs for employerID: \(employerID)")
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let fetchedJobs = try await JobManager.shared.fetchJobsByEmployer(employerID: employerID)
            print("✅ EmployerJobsView: Fetched \(fetchedJobs.count) jobs")
            
            // Load application counts for all jobs
            var counts: [String: Int] = [:]
            for job in fetchedJobs {
                do {
                    let count = try await ApplicationManager.shared.countApplicationsByJob(jobID: job.id)
                    counts[job.id] = count
                } catch {
                    print("⚠️ Error counting applications for job \(job.id): \(error.localizedDescription)")
                    counts[job.id] = 0
                }
            }
            
            await MainActor.run {
                self.jobs = fetchedJobs
                self.applicationCounts = counts
                isLoading = false
                errorMessage = nil
            }
        } catch {
            await MainActor.run {
                isLoading = false
                let errorDesc = error.localizedDescription
                errorMessage = "Failed to load jobs: \(errorDesc)"
                print("❌ Error loading jobs: \(errorDesc)")
                print("❌ Full error: \(error)")
            }
        }
    }
    
    private func loadApplications() async {
        guard let employerID = appState.uid else {
            print("⚠️ EmployerJobsView: No employerID found for loading applications")
            return
        }
        
        print("🔍 EmployerJobsView: Loading applications for employerID: \(employerID)")
        await MainActor.run {
            isLoadingApplications = true
        }
        
        do {
            let fetchedApplications = try await ApplicationManager.shared.fetchApplicationsByEmployer(employerID: employerID)
            print("✅ EmployerJobsView: Fetched \(fetchedApplications.count) applications")
            
            // Filter out applications from completed jobs
            let completedJobIDs = Set(jobs.filter { $0.status == "completed" || $0.status == "closed" }.map { $0.id })
            let filteredApplications = fetchedApplications.filter { !completedJobIDs.contains($0.jobID) }
            
            print("✅ EmployerJobsView: Filtered to \(filteredApplications.count) applications (excluding completed jobs)")
            await MainActor.run {
                self.applications = filteredApplications
                isLoadingApplications = false
            }
        } catch {
            await MainActor.run {
                isLoadingApplications = false
                let errorDesc = error.localizedDescription
                print("❌ Error loading applications: \(errorDesc)")
                print("❌ Full error: \(error)")
            }
        }
    }
    
    private func refreshApplicationCounts() async {
        var counts: [String: Int] = [:]
        for job in jobs {
            do {
                let count = try await ApplicationManager.shared.countApplicationsByJob(jobID: job.id)
                counts[job.id] = count
            } catch {
                print("⚠️ Error counting applications for job \(job.id): \(error.localizedDescription)")
                counts[job.id] = 0
            }
        }
        
        await MainActor.run {
            self.applicationCounts = counts
        }
    }
}

#Preview {
    EmployerJobsView()
        .environmentObject(AppState())
}
