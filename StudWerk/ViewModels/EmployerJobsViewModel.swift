//
//  EmployerJobsViewModel.swift
//  StudWerk
//
//  Created on 07.01.26.
//

import Foundation
import Combine

enum EmployerJobsTab: Int {
    case active = 0
    case applications = 1
    case completed = 2
}

@MainActor
final class EmployerJobsViewModel: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var applications: [Application] = []
    @Published var applicationCounts: [String: Int] = [:] // jobID -> count
    @Published var selectedTab: EmployerJobsTab = .active
    @Published var isLoading = false
    @Published var isLoadingApplications = false
    @Published var errorMessage: String? = nil
    
    var employerID: String = ""
    
    init(employerID: String = "") {
        self.employerID = employerID
    }
    
    // MARK: - Computed Properties
    
    var activeJobsList: [EmployerJob] {
        jobs.filter { job in
            job.jobStatus == .open
        }
        .map { job in
            convertToEmployerJob(job)
        }
    }
    
    var completedJobsList: [EmployerJob] {
        jobs.filter { job in
            job.jobStatus == .completed || job.jobStatus == .closed
        }
        .map { job in
            convertToEmployerJob(job)
        }
    }
    
    var filteredApplications: [Application] {
        // Filter out applications from completed jobs
        let completedJobIDs = Set(jobs.filter { $0.jobStatus == .completed || $0.jobStatus == .closed }.map { $0.id })
        return applications.filter { !completedJobIDs.contains($0.jobID) }
    }
    
    // MARK: - Methods
    
    func loadData() async {
        await loadJobs()
        await loadApplications()
    }
    
    func loadJobs() async {
        guard !employerID.isEmpty else {
            return
        }
        
        isLoading = true
        
        do {
            let fetchedJobs = try await JobManager.shared.fetchJobsByEmployer(employerID: employerID)
            self.jobs = fetchedJobs
            isLoading = false
        } catch {
            isLoading = false
            print("Error loading jobs: \(error.localizedDescription)")
        }
    }
    
    func loadApplications() async {
        guard !employerID.isEmpty else {
            return
        }
        
        isLoadingApplications = true
        
        do {
            let fetchedApplications = try await ApplicationManager.shared.fetchApplicationsByEmployer(employerID: employerID)
            print("EmployerJobsViewModel: Fetched \(fetchedApplications.count) applications")
            
            // Calculate application counts per job
            var counts: [String: Int] = [:]
            for application in fetchedApplications {
                counts[application.jobID, default: 0] += 1
            }
            applicationCounts = counts
            
            self.applications = fetchedApplications
            isLoadingApplications = false
        } catch {
            isLoadingApplications = false
            print("Error loading applications: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Helpers
    
    private func convertToEmployerJob(_ job: Job) -> EmployerJob {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let status: EmployerJobDisplayStatus
        switch job.jobStatus {
        case .open:
            status = .active
        case .closed:
            status = .paused
        case .completed:
            status = .completed
        case .filled:
            status = .expired
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
}
