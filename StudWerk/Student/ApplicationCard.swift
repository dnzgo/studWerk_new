//
//  ApplicationCard.swift
//  StudWerk
//
//  Created by Deniz Gözcü on 07.01.26.
//

import SwiftUI

struct ApplicationCard: View {
    let application: JobApplication
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(application.company)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Text(application.position)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                StatusBadge(status: application.status)
            }
            
            HStack {
                Image(systemName: "eurosign.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                
                Text(application.pay)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "calendar")
                    .foregroundColor(.orange)
                    .font(.caption)
                
                Text(application.appliedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if application.status == .pending {
                HStack {
                    Button("Withdraw") {
                        // Handle withdraw
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                    
                    Spacer()
                    
                    Button("View Details") {
                        // Handle view details
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
            } else if application.status == .accepted {
                HStack {
                    Button("Contact Employer") {
                        // Handle contact
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button("View Contract") {
                        // Handle view contract
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                }
            } else {
                HStack {
                    
                    Spacer()
                    
                    Button("View Details") {
                        // Handle view details
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

struct StatusBadge: View {
    let status: ApplicationStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(status.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.color.opacity(0.2))
            .cornerRadius(6)
    }
}

struct JobApplication: Identifiable {
    let id = UUID()
    let company: String
    let position: String
    let pay: String
    let appliedDate: String
    let status: ApplicationStatus
}

enum ApplicationStatus: String, CaseIterable {
    case pending = "Pending"
    case accepted = "Accepted"
    case completed = "Completed"
    case rejected = "Rejected"
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .accepted: return .green
        case .completed: return .blue
        case .rejected: return .red
        }
    }
}
