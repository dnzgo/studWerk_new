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
    @State private var applications: [Application] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else if applications.isEmpty {
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
                    ForEach(applications, id: \.id) { application in
                        EmployerApplicationCard(application: application)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .navigationTitle("Applications")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadApplications()
        }
        .refreshable {
            await loadApplications()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ApplicationStatusUpdated"))) { _ in
            Task {
                await loadApplications()
            }
        }
        .alert("Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func loadApplications() async {
        print("🔍 JobApplicationsView: Loading applications for job \(job.id)")
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let fetchedApplications = try await ApplicationManager.shared.fetchApplicationsByJob(jobID: job.id)
            print("✅ JobApplicationsView: Fetched \(fetchedApplications.count) applications")
            await MainActor.run {
                self.applications = fetchedApplications
                isLoading = false
                errorMessage = nil
            }
        } catch {
            await MainActor.run {
                isLoading = false
                let errorDesc = error.localizedDescription
                errorMessage = "Failed to load applications: \(errorDesc)"
                print("❌ Error loading applications: \(errorDesc)")
                print("❌ Full error: \(error)")
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

