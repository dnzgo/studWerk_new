//
//  StudentHomeViewModel.swift
//  StudWerk
//
//  Created on 07.01.26.
//

import Foundation
import Combine

@MainActor
final class StudentHomeViewModel: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var applications: [Application] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    var studentID: String = ""
    
    init(studentID: String = "") {
        self.studentID = studentID
    }
    
    // MARK: - Computed Properties
    
    var featuredJobs: [Job] {
        let appliedJobIDs = Set(applications.map { $0.jobID })
        return Array(jobs
            .filter { !appliedJobIDs.contains($0.id) }
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(3))
    }
    
    var nearbyJobs: [Job] {
        let appliedJobIDs = Set(applications.map { $0.jobID })
        return jobs
            .filter { !appliedJobIDs.contains($0.id) }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    var applicationsCount: Int {
        applications.filter { $0.applicationStatus == .pending }.count
    }
    
    var completedJobsCount: Int {
        applications.filter { $0.applicationStatus == .completed }.count
    }
    
    var totalEarnings: Int {
        let completed = applications.filter { app in
            app.applicationStatus == .completed
        }
        
        return completed.reduce(0) { total, app in
            let paymentString = app.jobPayment
            let numbers = paymentString.components(separatedBy: CharacterSet.decimalDigits.inverted)
                .compactMap { Int($0) }
            let amount = numbers.first ?? 0
            return total + amount
        }
    }
    
    // MARK: - Data Loading
    
    func loadData() async {
        await loadJobs()
        await loadApplications()
    }
    
    private func loadJobs() async {
        print("StudentHomeViewModel: Loading jobs")
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedJobs = try await JobManager.shared.fetchJobs(status: .open)
            print("StudentHomeViewModel: Fetched \(fetchedJobs.count) jobs")
            self.jobs = fetchedJobs
            isLoading = false
            errorMessage = nil
        } catch {
            isLoading = false
            let errorDesc = error.localizedDescription
            errorMessage = "Failed to load jobs: \(errorDesc)"
            print("Error loading jobs: \(errorDesc)")
        }
    }
    
    private func loadApplications() async {
        do {
            let fetchedApplications = try await ApplicationManager.shared.fetchApplicationsByStudent(studentID: studentID)
            self.applications = fetchedApplications
        } catch {
            print("Error loading applications: \(error.localizedDescription)")
        }
    }
}
