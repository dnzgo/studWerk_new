//
//  JobApplicationCard.swift
//  StudWerk
//
//  Created by Deniz Gözcü on 07.01.26.
//

import SwiftUI

struct JobApplicationCard: View {
    let application: JobApplicationDetail
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(application.studentName)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(application.position)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ApplicationStatusBadge(status: application.status)
            }
            
            HStack {
                
                Spacer()
                
                Image(systemName: "clock")
                    .foregroundColor(.orange)
                    .font(.caption)
                
                Text(application.appliedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !application.experience.isEmpty {
                Text(application.experience)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Button("View Profile") {
                    // Handle view profile
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                
                Spacer()
                
                if application.status == .pending {
                    HStack(spacing: 8) {
                        Button("Reject") {
                            // Handle reject
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        
                        Button("Accept") {
                            // Handle accept
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .cornerRadius(6)
                    }
                } else {
                    Button("Contact") {
                        // Handle contact
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct JobApplicationDetail: Identifiable {
    let id = UUID()
    let studentName: String
    let position: String
    let rating: Double
    let appliedDate: String
    let experience: String
    let status: ApplicationStatus
}
