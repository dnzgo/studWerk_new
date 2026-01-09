//
//  ApplicationCardViewModel.swift
//  StudWerk
//
//  Created on 07.01.26.
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class ApplicationCardViewModel: ObservableObject {
    let application: Application
    
    @Published var companyName = ""
    @Published var isWithdrawing = false
    @Published var showingWithdrawAlert = false
    @Published var showingErrorAlert = false
    @Published var errorMessage = ""
    @Published var showingJobDetail = false
    @Published var showingEmployerContact = false
    @Published var job: Job? = nil
    @Published var isLoadingJob = false
    @Published var employerEmail = ""
    @Published var employerPhone = ""
    @Published var employerAddress = ""
    
    init(application: Application) {
        self.application = application
    }
    
    // MARK: - Methods
    
    func loadCompanyName() async {
        do {
            if let name = try await JobManager.shared.fetchEmployerCompanyName(employerID: application.employerID) {
                companyName = name
            }
            // Also load employer contact info
            await loadEmployerContact()
        } catch {
            print("Error loading company name: \(error.localizedDescription)")
        }
    }
    
    func loadEmployerContact() async {
        do {
            let db = Firestore.firestore()
            
            // Get phone and address from employers collection
            let employerDoc = try await db.collection("employers").document(application.employerID).getDocument()
            if let employerData = employerDoc.data() {
                employerPhone = employerData["phone"] as? String ?? ""
                employerAddress = employerData["address"] as? String ?? ""
            }
            
            // Get email from users collection
            let userDoc = try await db.collection("users").document(application.employerID).getDocument()
            if let userData = userDoc.data() {
                employerEmail = userData["email"] as? String ?? ""
            }
            
            print("Loaded employer contact - Email: \(employerEmail), Phone: \(employerPhone), Address: \(employerAddress)")
        } catch {
            print("Error loading employer contact: \(error.localizedDescription)")
        }
    }
    
    func loadJobAndShowDetail() async {
        print("ApplicationCardViewModel: Loading job details for jobID: \(application.jobID)")
        
        isLoadingJob = true
        job = nil
        showingJobDetail = false
        
        do {
            if let fetchedJob = try await JobManager.shared.fetchJob(byID: application.jobID) {
                print("ApplicationCardViewModel: Successfully loaded job: \(fetchedJob.jobTitle)")
                job = fetchedJob
                isLoadingJob = false
                showingJobDetail = true
            } else {
                print("ApplicationCardViewModel: Job not found for ID: \(application.jobID)")
                isLoadingJob = false
                errorMessage = "Job not found"
                showingErrorAlert = true
            }
        } catch {
            print("ApplicationCardViewModel: Error loading job: \(error.localizedDescription)")
            isLoadingJob = false
            errorMessage = "Failed to load job details: \(error.localizedDescription)"
            showingErrorAlert = true
        }
    }
    
    func showWithdrawAlert() {
        showingWithdrawAlert = true
    }
    
    func performWithdraw() async {
        isWithdrawing = true
        
        do {
            try await ApplicationManager.shared.withdrawApplication(applicationID: application.id)
            isWithdrawing = false
            // Post notification to reload applications
            NotificationCenter.default.post(name: NSNotification.Name("ApplicationWithdrawn"), object: nil)
        } catch {
            isWithdrawing = false
            errorMessage = "Failed to withdraw application: \(error.localizedDescription)"
            showingErrorAlert = true
        }
    }
}
