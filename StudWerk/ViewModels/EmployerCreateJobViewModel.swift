//
//  EmployerCreateJobViewModel.swift
//  StudWerk
//
//  Created on 07.01.26.
//

import Foundation
import Combine

@MainActor
final class EmployerCreateJobViewModel: ObservableObject {
    @Published var jobTitle = ""
    @Published var jobDescription = ""
    @Published var payment = ""
    @Published var selectedDate = Date()
    @Published var startTime = Date()
    @Published var endTime = Date()
    @Published var selectedCategory = "General"
    @Published var location = ""
    @Published var isCreating = false
    @Published var showingSuccessAlert = false
    @Published var showingErrorAlert = false
    @Published var errorMessage = ""
    
    var employerID: String = ""
    
    let categories = ["General", "Technology", "Retail", "Food Service", "Marketing", "Administration", "Customer Service", "Other"]
    
    // MARK: - Computed Properties
    
    var isFormValid: Bool {
        !jobTitle.isEmpty &&
        !jobDescription.isEmpty &&
        !payment.isEmpty &&
        !location.isEmpty &&
        isValidPayment(payment)
    }
    
    // MARK: - Methods
    
    func createJob() async {
        guard !employerID.isEmpty else {
            errorMessage = "You must be logged in to create a job."
            showingErrorAlert = true
            return
        }
        
        guard isFormValid else {
            errorMessage = "Please fill in all required fields correctly."
            showingErrorAlert = true
            return
        }
        
        isCreating = true
        
        do {
            _ = try await JobManager.shared.createJob(
                employerID: employerID,
                jobTitle: jobTitle,
                jobDescription: jobDescription,
                payment: payment,
                date: selectedDate,
                startTime: startTime,
                endTime: endTime,
                category: selectedCategory,
                location: location
            )
            
            isCreating = false
            showingSuccessAlert = true
        } catch {
            isCreating = false
            errorMessage = error.localizedDescription
            showingErrorAlert = true
        }
    }
    
    func resetForm() {
        jobTitle = ""
        jobDescription = ""
        payment = ""
        selectedDate = Date()
        startTime = Date()
        endTime = Date()
        selectedCategory = "General"
        location = ""
    }
    
    // MARK: - Private Helpers
    
    private func isValidPayment(_ payment: String) -> Bool {
        // Check if payment is a valid number
        let numbers = payment.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
        return !numbers.isEmpty && Double(numbers) != nil && Double(numbers)! > 0
    }
}
