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
        }
    }
}



let pendingApplications = [
    JobApplication(company: "Tech Startup GmbH", position: "Software Developer Intern", pay: "€180", appliedDate: "2 days ago", status: .pending),
    JobApplication(company: "Café Central", position: "Barista", pay: "€100", appliedDate: "1 week ago", status: .pending),
    JobApplication(company: "Retail Store ABC", position: "Sales Assistant", pay: "€140", appliedDate: "3 days ago", status: .pending)
]

let acceptedApplications = [
    JobApplication(company: "Marketing Agency", position: "Social Media Manager", pay: "€16", appliedDate: "2 weeks ago", status: .accepted),
    JobApplication(company: "Restaurant XYZ", position: "Waiter", pay: "€13", appliedDate: "1 week ago", status: .accepted)
]

let completedApplications = [
    JobApplication(company: "Digital Agency", position: "Content Writer", pay: "€150", appliedDate: "1 month ago", status: .completed),
    JobApplication(company: "Tech Company", position: "Data Entry", pay: "€150", appliedDate: "2 months ago", status: .completed)
]

#Preview {
    StudentApplicationsView()
}
