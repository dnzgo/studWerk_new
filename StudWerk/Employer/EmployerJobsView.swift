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

struct EmployerJobCard: View {
    let job: EmployerJob
    let originalJob: Job?
    @EnvironmentObject var appState: AppState
    @State private var showingJobApplications = false
    @State private var showingEditJob = false
    
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
                        showingEditJob = true
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button("View Applications") {
                        showingJobApplications = true
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(6)
                }
            }
            .sheet(isPresented: $showingJobApplications) {
                if let originalJob = originalJob {
                    NavigationView {
                        JobApplicationsView(job: originalJob)
                            .environmentObject(appState)
                    }
                }
            }
            .sheet(isPresented: $showingEditJob) {
                if let originalJob = originalJob {
                    NavigationView {
                        EmployerEditJobView(job: originalJob)
                            .environmentObject(appState)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

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
            print("✅ Updated application \(application.id) to \(status.rawValue)")
            // Post notification to reload applications
            NotificationCenter.default.post(name: NSNotification.Name("ApplicationStatusUpdated"), object: nil)
        } catch {
            print("❌ Error updating application status: \(error.localizedDescription)")
        }
    }
    
    private func completeJob() async {
        do {
            try await ApplicationManager.shared.completeJob(applicationID: application.id)
            print("✅ Completed job for application \(application.id)")
            // Post notification to reload applications and jobs
            NotificationCenter.default.post(name: NSNotification.Name("ApplicationStatusUpdated"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("JobStatusUpdated"), object: nil)
        } catch {
            print("❌ Error completing job: \(error.localizedDescription)")
        }
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

#Preview {
    EmployerJobsView()
        .environmentObject(AppState())
}
