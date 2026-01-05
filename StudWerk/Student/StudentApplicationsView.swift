//
//  StudentApplicationsView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI

struct StudentApplicationsView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("Status", selection: $selectedTab) {
                    Text("Pending").tag(0)
                    Text("Accepted").tag(1)
                    Text("Completed").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Content
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if selectedTab == 0 {
                            ForEach(pendingApplications, id: \.id) { application in
                                ApplicationCard(application: application)
                            }
                        } else if selectedTab == 1 {
                            ForEach(acceptedApplications, id: \.id) { application in
                                ApplicationCard(application: application)
                            }
                        } else {
                            ForEach(completedApplications, id: \.id) { application in
                                ApplicationCard(application: application)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("My Applications")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

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
                    Button("Rate Experience") {
                        // Handle rating
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                    
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

let pendingApplications = [
    JobApplication(company: "Tech Startup GmbH", position: "Software Developer Intern", pay: "€18/hour", appliedDate: "2 days ago", status: .pending),
    JobApplication(company: "Café Central", position: "Barista", pay: "€12/hour", appliedDate: "1 week ago", status: .pending),
    JobApplication(company: "Retail Store ABC", position: "Sales Assistant", pay: "€14/hour", appliedDate: "3 days ago", status: .pending)
]

let acceptedApplications = [
    JobApplication(company: "Marketing Agency", position: "Social Media Manager", pay: "€16/hour", appliedDate: "2 weeks ago", status: .accepted),
    JobApplication(company: "Restaurant XYZ", position: "Waiter", pay: "€13/hour", appliedDate: "1 week ago", status: .accepted)
]

let completedApplications = [
    JobApplication(company: "Digital Agency", position: "Content Writer", pay: "€15/hour", appliedDate: "1 month ago", status: .completed),
    JobApplication(company: "Tech Company", position: "Data Entry", pay: "€15/hour", appliedDate: "2 months ago", status: .completed)
]

#Preview {
    StudentApplicationsView()
}
