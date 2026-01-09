//
//  EmployerSearchView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI
import Combine
import FirebaseFirestore

struct EmployerJobsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = EmployerJobsViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("Status", selection: Binding(
                    get: { viewModel.selectedTab.rawValue },
                    set: { viewModel.selectedTab = EmployerJobsTab(rawValue: $0) ?? .active }
                )) {
                    Text("Active").tag(0)
                    Text("Applications").tag(1)
                    Text("Completed").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToApplications"))) { _ in
                    // Switch to Applications tab
                    viewModel.selectedTab = .applications
                }
                
                // Content
                ScrollView {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 40)
                    } else {
                        LazyVStack(spacing: 12) {
                            if viewModel.selectedTab == .active {
                                if viewModel.activeJobsList.isEmpty {
                                    VStack(spacing: 16) {
                                        Image(systemName: "briefcase")
                                            .font(.system(size: 50))
                                            .foregroundColor(.secondary)
                                        Text("No active jobs")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        Text("Create a new job to get started")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.top, 40)
                                } else {
                                    ForEach(viewModel.activeJobsList, id: \.id) { employerJob in
                                        EmployerJobCard(
                                            job: employerJob,
                                            originalJob: viewModel.jobs.first { $0.id == employerJob.id }
                                        )
                                    }
                                }
                            } else if viewModel.selectedTab == .applications {
                                // Applications tab
                                if viewModel.isLoadingApplications {
                                    ProgressView()
                                        .padding(.top, 40)
                                } else if viewModel.filteredApplications.isEmpty {
                                    VStack(spacing: 16) {
                                        Image(systemName: "doc.text")
                                            .font(.system(size: 50))
                                            .foregroundColor(.secondary)
                                        Text("No applications yet")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        Text("Applications will appear here when students apply to your jobs")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(.top, 40)
                                } else {
                                    ForEach(viewModel.filteredApplications, id: \.id) { application in
                                        EmployerApplicationCard(application: application)
                                    }
                                }
                            } else {
                                if viewModel.completedJobsList.isEmpty {
                                    VStack(spacing: 16) {
                                        Image(systemName: "checkmark.circle")
                                            .font(.system(size: 50))
                                            .foregroundColor(.secondary)
                                        Text("No completed jobs")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.top, 40)
                                } else {
                                    ForEach(completedJobsList, id: \.id) { employerJob in
                                        EmployerJobCard(
                                            job: employerJob,
                                            originalJob: jobs.first { $0.id == employerJob.id }
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
            }
            .navigationTitle("My Jobs")
        }
        .task {
            await loadJobs()
            await loadApplications()
        }
        .refreshable {
            await loadJobs()
            await loadApplications()
        }
        .onChange(of: selectedTab) { newValue in
            if newValue == 1 {
                Task {
                    await loadApplications()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ApplicationStatusUpdated"))) { _ in
            Task {
                await loadApplications()
                await refreshApplicationCounts()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("JobStatusUpdated"))) { _ in
            Task {
                await loadJobs()
                await loadApplications()
            }
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
    EmployerJobsView()
        .environmentObject(AppState())
}
