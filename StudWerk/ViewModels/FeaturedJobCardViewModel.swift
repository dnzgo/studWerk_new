//
//  FeaturedJobCardViewModel.swift
//  StudWerk
//
//  Created on 07.01.26.
//

import Foundation
import Combine

@MainActor
final class FeaturedJobCardViewModel: ObservableObject {
    let job: Job
    
    @Published var hasApplied = false
    @Published var isCheckingApplication = false
    @Published var showingJobDetail = false
    @Published var companyName = ""
    
    var studentID: String = ""
    
    init(job: Job, studentID: String = "") {
        self.job = job
        self.studentID = studentID
    }
    
    // MARK: - Methods
    
    func checkApplicationStatus() async {
        guard !studentID.isEmpty else {
            return
        }
        
        isCheckingApplication = true
        
        do {
            let applied = try await ApplicationManager.shared.hasAppliedToJob(jobID: job.id, studentID: studentID)
            hasApplied = applied
            isCheckingApplication = false
        } catch {
            isCheckingApplication = false
            print("Error checking application status: \(error.localizedDescription)")
        }
    }
    
    func loadCompanyName() async {
        do {
            if let name = try await JobManager.shared.fetchEmployerCompanyName(employerID: job.employerID) {
                companyName = name
            }
        } catch {
            print("Error loading company name: \(error.localizedDescription)")
        }
    }
}
