//
//  EmployerHomeView.swift
//  StudWerk
//
//  Created by Deniz Gözcü on 5.01.2026.
//

import SwiftUI

struct EmployerHomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = EmployerHomeViewModel()
    
    var body : some View {
        NavigationView {
            ScrollView {
                VStack (spacing : 24) {
                    // statistic cards
                    VStack(spacing : 16) {
                        HStack(spacing : 16) {
                            StatCard(
                                title: "Active Jobs",
                                value: "\(viewModel.activeJobsCount)",
                                color: .blue,
                                icon: "briefcase.fill")
                            
                            StatCard(
                                title: "Applications",
                                value: "\(viewModel.applicationsCount)",
                                color: .green,
                                icon: "doc.text.fill")
                        }
                        HStack(spacing : 16) {
                            StatCard(
                                title: "Hired Students",
                                value: "\(viewModel.hiredStudentsCount)",
                                color: .orange,
                                icon: "person.2.fill")
                            
                            StatCard(
                                title: "Total Spend",
                                value: "€\(viewModel.totalSpend)",
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
                                // Navigate to My Jobs tab and switch to Applications
                                NotificationCenter.default.post(
                                    name: NSNotification.Name("NavigateToApplications"),
                                    object: nil
                                )
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            if viewModel.recentApplications.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 50))
                                        .foregroundColor(.secondary)
                                    Text("No recent applications")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    Text("Applications will appear here when students apply to your jobs")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.top, 40)
                            } else {
                                ForEach(viewModel.recentApplications, id: \.id) { application in
                                    ApplicationSummaryCard(application: application)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            if let employerID = appState.uid {
                viewModel.employerID = employerID
                await viewModel.loadData()
            }
        }
        .refreshable {
            await viewModel.loadData()
        }
    }
}

#Preview {
    EmployerHomeView()
        .environmentObject(AppState())
}

