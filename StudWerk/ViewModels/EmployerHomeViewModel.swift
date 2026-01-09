//
//  EmployerHomeViewModel.swift
//  StudWerk
//
//  Created on 07.01.26.
//

import Foundation
import Combine

@MainActor
final class EmployerHomeViewModel: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var applications: [Application] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    var employerID: String = ""
    
    init(employerID: String = "") {
        self.employerID = employerID
    }
    
    // MARK: - Computed Properties
    
    var activeJobsCount: Int {
        jobs.filter { $0.jobStatus == .open }.count
    }
    
    var applicationsCount: Int {
        applications.filter { $0.applicationStatus == .pending }.count
    }
    
    var hiredStudentsCount: Int {
        applications.filter { $0.applicationStatus == .accepted || $0.applicationStatus == .completed }.count
    }
    
    var recentApplications: [Application] {
        return Array(applications
            .sorted { $0.appliedAt > $1.appliedAt }
            .prefix(5))
    }
    
    var totalSpend: String {
        let completed = applications.filter { app in
            app.applicationStatus == .completed
        }
        
        let total = completed.reduce(0) { total, app in
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
    
    // MARK: - Data Loading
    
    func loadData() async {
        await loadJobs()
        await loadApplications()
    }
    
    private func loadJobs() async {
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
    
    private func loadApplications() async {
        do {
            let fetchedApplications = try await ApplicationManager.shared.fetchApplicationsByEmployer(employerID: employerID)
            self.applications = fetchedApplications
        } catch {
            print("Error loading applications: \(error.localizedDescription)")
        }
    }
}
