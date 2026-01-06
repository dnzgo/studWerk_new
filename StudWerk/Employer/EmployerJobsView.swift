//
//  EmployerSearchView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI

struct EmployerJobsView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("Status", selection: $selectedTab) {
                    Text("Active").tag(0)
                    Text("Applications").tag(1)
                    Text("Completed").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Content
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if selectedTab == 0 {
                            ForEach(activeJobs, id: \.id) { job in
                                EmployerJobCard(job: job)
                            }
                        } else if selectedTab == 1 {
                            ForEach(jobApplications, id: \.id) { application in
                                JobApplicationCard(application: application)
                            }
                        } else {
                            ForEach(completedJobs, id: \.id) { job in
                                EmployerJobCard(job: job)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("My Jobs")
        }
    }
}

struct EmployerJobCard: View {
    let job: EmployerJob
    
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
                        // Handle edit
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button("View Applications") {
                        // Handle view applications
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(6)
                } else {
                    Button("View Details") {
                        // Handle view details
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button("Repost") {
                        // Handle repost
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

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
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                
                Text(String(format: "%.1f", application.rating))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
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

struct ApplicationStatusBadge: View {
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

struct EmployerJob: Identifiable {
    let id = UUID()
    let position: String
    let category: String
    let pay: String
    let date: String
    let location: String
    let applications: Int
    let description: String
    let status: JobStatus
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


let activeJobs = [
    EmployerJob(position: "Garden Cleaning", category: "General", pay: "€50", date: "Dec 20, 2024", location: "Charlottenburg, Berlin", applications: 3, description: "One-time garden cleaning job for private home.", status: .active),
    EmployerJob(position: "Wall Painting", category: "General", pay: "€120", date: "Dec 22, 2024", location: "Mitte, Berlin", applications: 5, description: "Painting apartment walls, one-time job.", status: .active),
    EmployerJob(position: "Office Cleaning", category: "General", pay: "€80", date: "Dec 25, 2024", location: "Potsdamer Platz, Berlin", applications: 8, description: "Evening office cleaning, one-time job.", status: .active)
]

let jobApplications = [
    JobApplicationDetail(studentName: "Max Mustermann", position: "Software Developer Intern", rating: 4.5, appliedDate: "2 days ago", experience: "Computer Science student with experience in Python and JavaScript", status: .pending),
    JobApplicationDetail(studentName: "Anna Schmidt", position: "Marketing Assistant", rating: 4.2, appliedDate: "1 day ago", experience: "Marketing student with social media experience", status: .pending),
    JobApplicationDetail(studentName: "Tom Weber", position: "Sales Assistant", rating: 4.8, appliedDate: "3 days ago", experience: "Business student with retail experience", status: .accepted)
]

let completedJobs = [
    EmployerJob(position: "Garden Cleaning", category: "General", pay: "€45", date: "Nov 30, 2024", location: "Charlottenburg, Berlin", applications: 2, description: "Completed garden cleaning job", status: .completed),
    EmployerJob(position: "Wall Painting", category: "General", pay: "€100", date: "Nov 25, 2024", location: "Mitte, Berlin", applications: 3, description: "Completed wall painting job", status: .completed)
]

#Preview {
    EmployerJobsView()
}
