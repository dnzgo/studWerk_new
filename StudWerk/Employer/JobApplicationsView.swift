//
//  JobApplicationsView.swift
//  StudWerk
//
//  Created on 07.01.26.
//

import SwiftUI
import FirebaseFirestore

struct JobApplicationsView: View {
    let job: Job
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: JobApplicationsViewModel
    
    init(job: Job) {
        self.job = job
        _viewModel = StateObject(wrappedValue: JobApplicationsViewModel(jobID: job.id))
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else if viewModel.applications.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("No applications yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Applications will appear here when students apply to this job")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                } else {
                    ForEach(viewModel.applications, id: \.id) { application in
                        EmployerApplicationCard(application: application)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .navigationTitle("Applications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .task {
            await viewModel.loadApplications()
        }
        .refreshable {
            await viewModel.loadApplications()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ApplicationStatusUpdated"))) { _ in
            Task {
                await viewModel.loadApplications()
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
    NavigationView {
        JobApplicationsView(job: Job(
            id: "1",
            employerID: "emp1",
            jobTitle: "Software Developer",
            jobDescription: "We are looking for...",
            payment: "150",
            date: Date(),
            startTime: Date(),
            endTime: Date(),
            category: "Technology",
            location: "Berlin",
            createdAt: Date(),
            status: "open"
        ))
        .environmentObject(AppState())
    }
}

