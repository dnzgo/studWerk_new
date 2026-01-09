//
//  JobDetailViewModel.swift
//  StudWerk
//
//  Created on 07.01.26.
//

import Foundation
import Combine

@MainActor
final class JobDetailViewModel: ObservableObject {
    let job: Job
    
    @Published var hasApplied = false
    @Published var isCheckingApplication = true
    @Published var isApplying = false
    @Published var showingSuccessAlert = false
    @Published var showingErrorAlert = false
    @Published var errorMessage = ""
    @Published var companyName = ""
    
    var studentID: String = ""
    
    init(job: Job, studentID: String = "") {
        self.job = job
        self.studentID = studentID
    }
    
    // MARK: - Methods
    
    func checkApplicationStatus() async {
        guard !studentID.isEmpty else {
            isCheckingApplication = false
            return
        }
        
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
    
    func applyToJob() async {
        guard !studentID.isEmpty else {
            errorMessage = "You must be logged in to apply"
            showingErrorAlert = true
            return
        }
        
        isApplying = true
        
        do {
            _ = try await ApplicationManager.shared.applyToJob(jobID: job.id, studentID: studentID)
            hasApplied = true
            isApplying = false
            showingSuccessAlert = true
        } catch {
            isApplying = false
            errorMessage = error.localizedDescription
            showingErrorAlert = true
        }
    }
}
