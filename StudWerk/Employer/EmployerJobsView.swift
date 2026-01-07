//
//  EmployerSearchView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI

struct EmployerJobsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var jobs: [Job] = []
    @State private var isLoading = false
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
                                    ForEach(activeJobsList, id: \.id) { job in
                                        EmployerJobCard(job: job)
                                    }
                                }
                            } else if selectedTab == 1 {
                                // Applications tab - keep mock data for now
                                ForEach(jobApplications, id: \.id) { application in
                                    JobApplicationCard(application: application)
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
                                    ForEach(completedJobsList, id: \.id) { job in
                                        EmployerJobCard(job: job)
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
        }
        .refreshable {
            await loadJobs()
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
        
        return EmployerJob(
            id: job.id,
            position: job.jobTitle,
            category: job.category,
            pay: job.pay,
            date: dateFormatter.string(from: job.date),
            location: job.location,
            applications: 0, // TODO: Fetch application count
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
                print("❌ Error loading jobs: \(errorDesc)")
                print("❌ Full error: \(error)")
            }
        }
    }
}

struct EmployerJobCard: View {
    let job: EmployerJob
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.position)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(job.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(6)
                }
                
                Spacer()
                
                JobStatusBadge(status: job.status)
            }
            
            HStack {
                Image(systemName: "eurosign.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                
                Text(job.pay)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "calendar")
                    .foregroundColor(.orange)
                    .font(.caption)
                
                Text(job.date)
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
                
                Text("\(job.applications) applications")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !job.description.isEmpty {
                Text(job.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                if job.status == .active {
                    Button("Edit Job") {
                        // Handle edit
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button("View Applications") {
                        // Handle view applications
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(6)
                } else {
                    Button("View Details") {
                        // Handle view details
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button("Repost") {
                        // Handle repost
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct JobApplicationCard: View {
    let application: JobApplicationDetail
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(application.studentName)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(application.position)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ApplicationStatusBadge(status: application.status)
            }
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                
                Text(String(format: "%.1f", application.rating))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "clock")
                    .foregroundColor(.orange)
                    .font(.caption)
                
                Text(application.appliedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !application.experience.isEmpty {
                Text(application.experience)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Button("View Profile") {
                    // Handle view profile
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                
                Spacer()
                
                if application.status == .pending {
                    HStack(spacing: 8) {
                        Button("Reject") {
                            // Handle reject
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        
                        Button("Accept") {
                            // Handle accept
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .cornerRadius(6)
                    }
                } else {
                    Button("Contact") {
                        // Handle contact
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
    }
}

struct JobStatusBadge: View {
    let status: JobStatus
    
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

struct EmployerJob: Identifiable {
    let id: String
    let position: String
    let category: String
    let pay: String
    let date: String
    let location: String
    let applications: Int
    let description: String
    let status: JobStatus
}

struct JobApplicationDetail: Identifiable {
    let id = UUID()
    let studentName: String
    let position: String
    let rating: Double
    let appliedDate: String
    let experience: String
    let status: ApplicationStatus
}

enum JobStatus: String, CaseIterable {
    case active = "Active"
    case paused = "Paused"
    case completed = "Completed"
    case expired = "Expired"
    
    var color: Color {
        switch self {
        case .active: return .green
        case .paused: return .orange
        case .completed: return .blue
        case .expired: return .red
        }
    }
}


// Mock data for applications tab (to be replaced with real data later)
let jobApplications = [
    JobApplicationDetail(studentName: "Max Mustermann", position: "Software Developer Intern", rating: 4.5, appliedDate: "2 days ago", experience: "Computer Science student with experience in Python and JavaScript", status: ApplicationStatus.pending),
    JobApplicationDetail(studentName: "Anna Schmidt", position: "Marketing Assistant", rating: 4.2, appliedDate: "1 day ago", experience: "Marketing student with social media experience", status: ApplicationStatus.pending),
    JobApplicationDetail(studentName: "Tom Weber", position: "Sales Assistant", rating: 4.8, appliedDate: "3 days ago", experience: "Business student with retail experience", status: ApplicationStatus.accepted)
]

#Preview {
    EmployerJobsView()
        .environmentObject(AppState())
}
