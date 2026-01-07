//
//  EmployerHomeView.swift
//  StudWerk
//
//  Created by Deniz Gözcü on 5.01.2026.
//

import SwiftUI

struct EmployerHomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var jobs: [Job] = []
    @State private var isLoading = false
    
    var body : some View {
        NavigationView {
            ScrollView {
                VStack (spacing : 24) {
                    // header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing : 4) {
                                Text("Dashboard")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                            
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    
                    // statistic cards
                    VStack(spacing : 16) {
                        HStack(spacing : 16) {
                            StatCard(
                                title: "Active Jobs",
                                value: "\(activeJobsCount)",
                                color: .blue,
                                icon: "briefcase.fill")
                            
                            StatCard(
                                title: "Applications",
                                value: "\(applicationsCount)",
                                color: .green,
                                icon: "doc.text.fill")
                        }
                        HStack(spacing : 16) {
                            StatCard(
                                title: "Hired Students",
                                value: "\(hiredStudentsCount)",
                                color: .orange,
                                icon: "person.2.fill")
                            
                            StatCard(
                                title: "Total Spend",
                                value: "€\(totalSpend)",
                                color: .purple,
                                icon: "eurosign.circle.fill")
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // recent applications
                    VStack(alignment : .leading, spacing : 16) {
                        HStack {
                            Text("Recent Applications")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Button("View All") {
                                // handle navigation to applications
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(recentApplications, id: \.id) { application in ApplicationSummaryCard(application: application)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
        }
        .task {
            await loadJobs()
        }
        .refreshable {
            await loadJobs()
        }
    }
    
    private var activeJobsCount: Int {
        jobs.filter { $0.status == "open" || $0.status == "active" }.count
    }
    
    private var applicationsCount: Int {
        // TODO: Fetch real application count
        0
    }
    
    private var hiredStudentsCount: Int {
        // TODO: Fetch real hired students count
        0
    }
    
    private var totalSpend: String {
        let total = jobs
            .filter { $0.status == "completed" || $0.status == "closed" }
            .compactMap { Double($0.payment) }
            .reduce(0, +)
        
        if total >= 1000 {
            return String(format: "%.1fK", total / 1000)
        } else {
            return String(format: "%.0f", total)
        }
    }
    
    private func loadJobs() async {
        guard let employerID = appState.uid else {
            return
        }
        
        isLoading = true
        
        do {
            let fetchedJobs = try await JobManager.shared.fetchJobsByEmployer(employerID: employerID)
            await MainActor.run {
                self.jobs = fetchedJobs
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                print("Error loading jobs: \(error.localizedDescription)")
            }
        }
    }
}


let recentApplications = [
    ApplicationSummary(studentName: "Max Mustermann", position: "Software Developer Intern", timeAgo: "2h ago"),
    ApplicationSummary(studentName: "Anna Schmidt", position: "Marketing Assistant", timeAgo: "4h ago"),
    ApplicationSummary(studentName: "Tom Weber", position: "Sales Assistant", timeAgo: "6h ago")
]


#Preview {
    EmployerHomeView()
        .environmentObject(AppState())
}
