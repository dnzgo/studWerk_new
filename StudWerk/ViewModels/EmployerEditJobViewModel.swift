//
//  EmployerEditJobViewModel.swift
//  StudWerk
//
//  Created on 07.01.26.
//

import Foundation
import Combine

@MainActor
final class EmployerEditJobViewModel: ObservableObject {
    let job: Job
    
    @Published var jobTitle: String
    @Published var jobDescription: String
    @Published var payment: String
    @Published var selectedDate: Date
    @Published var startTime: Date
    @Published var endTime: Date
    @Published var selectedCategory: String
    @Published var location: String
    @Published var isUpdating = false
    @Published var isDeleting = false
    @Published var showingSuccessAlert = false
    @Published var showingErrorAlert = false
    @Published var showingDeleteConfirmation = false
    @Published var showingDeleteSuccessAlert = false
    @Published var errorMessage = ""
    
    let categories = ["General", "Technology", "Retail", "Food Service", "Marketing", "Administration", "Customer Service", "Other"]
    
    init(job: Job) {
        self.job = job
        self.jobTitle = job.jobTitle
        self.jobDescription = job.jobDescription
        self.payment = job.payment
        self.selectedDate = job.date
        self.startTime = job.startTime
        self.endTime = job.endTime
        self.selectedCategory = job.category
        self.location = job.location
    }
    
    // MARK: - Computed Properties
    
    var isFormValid: Bool {
        !jobTitle.isEmpty &&
        !jobDescription.isEmpty &&
        !payment.isEmpty &&
        !location.isEmpty &&
        isValidPayment(payment)
    }
    
    // MARK: - Methods
    
    func updateJob() async {
        guard isFormValid else {
            errorMessage = "Please fill in all required fields correctly."
            showingErrorAlert = true
            return
        }
        
        isUpdating = true
        
        do {
            try await JobManager.shared.updateJob(
                jobID: job.id,
                jobTitle: jobTitle,
                jobDescription: jobDescription,
                payment: payment,
                date: selectedDate,
                startTime: startTime,
                endTime: endTime,
                category: selectedCategory,
                location: location
            )
            
            isUpdating = false
            showingSuccessAlert = true
            // Post notification to reload jobs
            NotificationCenter.default.post(name: NSNotification.Name("JobStatusUpdated"), object: nil)
        } catch {
            isUpdating = false
            errorMessage = error.localizedDescription
            showingErrorAlert = true
        }
    }
    
    func deleteJob() async {
        isDeleting = true
        
        do {
            // First, delete all applications for this job
            try await ApplicationManager.shared.deleteApplicationsByJob(jobID: job.id)
            
            // Then, delete the job itself
            try await JobManager.shared.deleteJob(jobID: job.id)
            
            isDeleting = false
            showingDeleteSuccessAlert = true
            // Post notification to reload jobs
            NotificationCenter.default.post(name: NSNotification.Name("JobStatusUpdated"), object: nil)
        } catch {
            isDeleting = false
            errorMessage = error.localizedDescription
            showingErrorAlert = true
        }
    }
    
    // MARK: - Private Helpers
    
    private func isValidPayment(_ payment: String) -> Bool {
        let numbers = payment.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
        return !numbers.isEmpty && Double(numbers) != nil && Double(numbers)! > 0
    }
}
