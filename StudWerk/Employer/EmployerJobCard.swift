//
//  EmployerJobCard.swift
//  StudWerk
//
//  Created by Deniz Gözcü on 07.01.26.
//

import SwiftUI

struct EmployerJobCard: View {
    let job: EmployerJob
    let originalJob: Job?
    @EnvironmentObject var appState: AppState
    @State private var showingJobApplications = false
    @State private var showingEditJob = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.position)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(job.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(6)
                }
                
                Spacer()
                
                JobStatusBadge(status: job.status)
            }
            
            HStack {
                Image(systemName: "eurosign.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                
                Text(job.pay)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "calendar")
                    .foregroundColor(.orange)
                    .font(.caption)
                
                Text(job.date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Text(job.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(job.applications) applications")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !job.description.isEmpty {
                Text(job.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                if job.status == .active {
                    Button("Edit Job") {
                        showingEditJob = true
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button("View Applications") {
                        showingJobApplications = true
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(6)
                }
            }
            .sheet(isPresented: $showingJobApplications) {
                if let originalJob = originalJob {
                    NavigationView {
                        JobApplicationsView(job: originalJob)
                            .environmentObject(appState)
                    }
                }
            }
            .sheet(isPresented: $showingEditJob) {
                if let originalJob = originalJob {
                    NavigationView {
                        EmployerEditJobView(job: originalJob)
                            .environmentObject(appState)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct EmployerJob: Identifiable {
    let id: String
    let position: String
    let category: String
    let pay: String
    let date: String
    let location: String
    let applications: Int
    let description: String
    let status: JobStatus
}



struct JobStatusBadge: View {
    let status: JobStatus
    
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

enum JobStatus: String, CaseIterable {
    case active = "Active"
    case paused = "Paused"
    case completed = "Completed"
    case expired = "Expired"
    
    var color: Color {
        switch self {
        case .active: return .green
        case .paused: return .orange
        case .completed: return .blue
        case .expired: return .red
        }
    }
}
