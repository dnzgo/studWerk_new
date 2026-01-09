//
//  JobApplicationsViewModel.swift
//  StudWerk
//
//  Created on 07.01.26.
//

import Foundation
import Combine

@MainActor
final class JobApplicationsViewModel: ObservableObject {
    let jobID: String
    
    @Published var applications: [Application] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    init(jobID: String) {
        self.jobID = jobID
    }
    
    // MARK: - Methods
    
    func loadApplications() async {
        print("JobApplicationsViewModel: Loading applications for job \(jobID)")
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedApplications = try await ApplicationManager.shared.fetchApplicationsByJob(jobID: jobID)
            print("JobApplicationsViewModel: Fetched \(fetchedApplications.count) applications")
            self.applications = fetchedApplications
            isLoading = false
            errorMessage = nil
        } catch {
            isLoading = false
            let errorDesc = error.localizedDescription
            errorMessage = "Failed to load applications: \(errorDesc)"
            print("Error loading applications: \(errorDesc)")
        }
    }
}
