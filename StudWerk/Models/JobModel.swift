//
//  JobModel.swift
//  StudWerk
//
//  Created by Deniz Gözcü on 06.01.26.
//

import SwiftUI

struct Job: Identifiable, Codable {
    let id: String  // Firestore document ID
    let employerID: String
    let jobTitle: String
    let jobDescription: String
    let payment: String
    let date: Date
    let startTime: Date
    let endTime: Date
    let category: String
    let location: String
    let createdAt: Date
    let status: String
    
    // Computed properties for display
    var company: String { "" } // from employer
    var position: String { jobTitle }
    var pay: String { "€\(payment)" }
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        
        let dateStr = dateFormatter.string(from: date)
        let startStr = timeFormatter.string(from: startTime)
        let endStr = timeFormatter.string(from: endTime)
        
        return "\(dateStr), \(startStr)-\(endStr)"
    }
    var description: String { jobDescription }
    var distance: String { "N/A" } // TODO: Calculate based on user location
}
