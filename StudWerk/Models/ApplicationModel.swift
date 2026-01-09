//
//  ApplicationModel.swift
//  StudWerk
//
//  Created on 07.01.26.
//

import Foundation

struct Application: Identifiable, Codable {
    let id: String  // Firestore document ID
    let studentID: String
    let jobID: String
    let employerID: String
    let status: String  // ApplicationStatus raw value
    let appliedAt: Date
    let jobTitle: String
    let jobPayment: String
    let jobLocation: String
    let jobDate: Date
    let jobStartTime: Date
    let jobEndTime: Date
    let jobCategory: String
    
    // Computed property for type-safe status (similar to Job.jobStatus)
    var applicationStatus: ApplicationStatus {
        ApplicationStatus(rawValue: status) ?? .pending
    }
    
    // Computed properties for display
    
    var position: String { jobTitle }
    
    var pay: String { "€\(jobPayment)" }
    
    var appliedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: appliedAt, relativeTo: Date())
    }
    
    var company: String { "" } // Will be fetched from employer collection
    var location: String { jobLocation }
    var category: String { jobCategory }
    
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        
        let dateStr = dateFormatter.string(from: jobDate)
        let startStr = timeFormatter.string(from: jobStartTime)
        let endStr = timeFormatter.string(from: jobEndTime)
        
        return "\(dateStr), \(startStr)-\(endStr)"
    }
}

