//
//  JobModel.swift
//  StudWerk
//
//  Created by Deniz Gözcü on 06.01.26.
//

import SwiftUI

struct Job: Identifiable {
    let id = UUID()
    let company: String
    let position: String
    let pay: String
    let location: String
    let date: String
    let distance: String
}

enum JobType: String, CaseIterable {
    case oneTime = "One-time"
    case recurring = "Recurring"

    var color: Color {
        switch self {
        case .oneTime: return .blue
        case .recurring: return .green
        }
    }
}

// Extended Job model for search
extension Job {
    var category: String {
        // This would be determined by the job's actual category
        return "General" // Placeholder
    }

    var description: String {
        return "Looking for a motivated student to join our team. Great opportunity to gain experience in a professional environment."
    }

}

func getSampleJobs() -> [Job] {
    return [
        Job(company: "Private Home", position: "Garden Cleaning", pay: "€50", location: "Charlottenburg, Berlin", date: "Today, 14:00-17:00", distance: "0.8 km"),
        Job(company: "Individual", position: "Wall Painting", pay: "€120", location: "Mitte, Berlin", date: "Tomorrow, 10:00-16:00", distance: "1.5 km"),
        Job(company: "Office Building", position: "Office Cleaning", pay: "€80", location: "Potsdamer Platz, Berlin", date: "Dec 25, 18:00-22:00", distance: "2.1 km"),
        Job(company: "Tech Company", position: "Data Entry", pay: "€15/hour", location: "Friedrichshain, Berlin", date: "This week", distance: "2.1 km")
    ]
}
