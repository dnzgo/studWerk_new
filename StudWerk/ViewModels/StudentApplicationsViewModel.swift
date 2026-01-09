//
//  StudentApplicationsViewModel.swift
//  StudWerk
//
//  Created on 07.01.26.
//

import Foundation
import Combine

enum ApplicationTab: Int {
    case pending = 0
    case accepted = 1
    case completed = 2
}

@MainActor
final class StudentApplicationsViewModel: ObservableObject {
    @Published var applications: [Application] = []
    @Published var selectedTab: ApplicationTab = .pending
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    var studentID: String = ""
    
    init(studentID: String = "") {
        self.studentID = studentID
    }
    
    // MARK: - Computed Properties
    
    var filteredApplications: [Application] {
        switch selectedTab {
        case .pending:
            return applications.filter { $0.applicationStatus == .pending }
        case .accepted:
            return applications.filter { $0.applicationStatus == .accepted }
        case .completed:
            return applications.filter { $0.applicationStatus == .completed }
        }
    }
    
    // MARK: - Methods
    
    func loadApplications() async {
        guard !studentID.isEmpty else {
            errorMessage = "You must be logged in to view applications"
            return
        }
        
        print("StudentApplicationsViewModel: Loading applications for student \(studentID)")
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedApplications = try await ApplicationManager.shared.fetchApplicationsByStudent(studentID: studentID)
            print("StudentApplicationsViewModel: Fetched \(fetchedApplications.count) applications")
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
