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
                tabSelector
                contentView
            }
            .navigationTitle("My Jobs")
        }
        .task {
            viewModel.employerID = appState.uid ?? ""
            await viewModel.loadData()
        }
        .refreshable {
            await viewModel.loadData()
        }
        .onChange(of: viewModel.selectedTab) { newValue in
            if newValue == .applications {
                Task {
                    await viewModel.loadApplications()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToApplications"))) { _ in
            viewModel.selectedTab = .applications
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ApplicationStatusUpdated"))) { _ in
            Task {
                await viewModel.loadApplications()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("JobStatusUpdated"))) { _ in
            Task {
                await viewModel.loadData()
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
    
    // MARK: - View Components
    
    private var tabSelector: some View {
        Picker("Status", selection: $viewModel.selectedTab) {
            Text("Active").tag(EmployerJobsTab.active)
            Text("Applications").tag(EmployerJobsTab.applications)
            Text("Completed").tag(EmployerJobsTab.completed)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var contentView: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 40)
            } else {
                LazyVStack(spacing: 12) {
                    tabContent
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
    }
    
    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.selectedTab {
        case .active:
            activeJobsContent
        case .applications:
            applicationsContent
        case .completed:
            completedJobsContent
        }
    }
    
    @ViewBuilder
    private var activeJobsContent: some View {
        if viewModel.activeJobsList.isEmpty {
            emptyStateView(
                icon: "briefcase",
                title: "No active jobs",
                message: "Create a new job to get started"
            )
        } else {
            ForEach(viewModel.activeJobsList, id: \.id) { employerJob in
                EmployerJobCard(
                    job: employerJob,
                    originalJob: findOriginalJob(for: employerJob.id)
                )
            }
        }
    }
    
    @ViewBuilder
    private var applicationsContent: some View {
        if viewModel.isLoadingApplications {
            ProgressView()
                .padding(.top, 40)
        } else if viewModel.filteredApplications.isEmpty {
            emptyStateView(
                icon: "doc.text",
                title: "No applications yet",
                message: "Applications will appear here when students apply to your jobs"
            )
        } else {
            ForEach(viewModel.filteredApplications, id: \.id) { application in
                EmployerApplicationCard(application: application)
            }
        }
    }
    
    @ViewBuilder
    private var completedJobsContent: some View {
        if viewModel.completedJobsList.isEmpty {
            emptyStateView(
                icon: "checkmark.circle",
                title: "No completed jobs",
                message: nil
            )
        } else {
            ForEach(viewModel.completedJobsList, id: \.id) { employerJob in
                EmployerJobCard(
                    job: employerJob,
                    originalJob: findOriginalJob(for: employerJob.id)
                )
            }
        }
    }
    
    private func emptyStateView(icon: String, title: String, message: String?) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 40)
    }
    
    private func findOriginalJob(for jobID: String) -> Job? {
        viewModel.jobs.first { $0.id == jobID }
    }
}

#Preview {
    EmployerJobsView()
        .environmentObject(AppState())
}
