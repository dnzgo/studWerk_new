//
//  StudentHomeView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI

struct StudentHomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: StudentHomeViewModel
    
    init() {
        // Initialize with empty ID, will be set in onAppear
        _viewModel = StateObject(wrappedValue: StudentHomeViewModel(studentID: ""))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Find your next job opportunity")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    
                    // Quick Stats
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Completed",
                            value: "\(viewModel.completedJobsCount)",
                            color: .blue,
                            icon: "briefcase.fill"
                        )
                        
                        StatCard(
                            title: "Applications",
                            value: "\(viewModel.applicationsCount)",
                            color: .green,
                            icon: "doc.text.fill"
                        )
                        
                        StatCard(
                            title: "Earnings",
                            value: "€\(viewModel.totalEarnings)",
                            color: .orange,
                            icon: "eurosign.circle.fill"
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Featured Jobs Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Featured Jobs")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if viewModel.featuredJobs.isEmpty {
                            Text("No featured jobs available")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.featuredJobs.prefix(3), id: \.id) { job in
                                        FeaturedJobCard(job: job)
                                            .environmentObject(appState)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    // Nearby Jobs Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Nearby Jobs")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if viewModel.nearbyJobs.isEmpty {
                            Text("No nearby jobs available")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.nearbyJobs.prefix(5), id: \.id) { job in
                                    JobCard(job: job)
                                        .environmentObject(appState)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("StudWerk")
        }
        .task {
            // Set studentID if available
            if let studentID = appState.uid {
                viewModel.studentID = studentID
                await viewModel.loadData()
            }
        }
        .refreshable {
            await viewModel.loadData()
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}
#Preview {
    StudentHomeView()
}
