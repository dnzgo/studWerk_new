//
//  StudentApplicationsView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI

struct StudentApplicationsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var applications: [Application] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
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
                        if isLoading {
                            ProgressView()
                                .padding(.top, 40)
                        } else if filteredApplications.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 50))
                                    .foregroundColor(.secondary)
                                Text("No applications found")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 40)
                        } else {
                            ForEach(filteredApplications, id: \.id) { application in
                                ApplicationCard(application: application)
                                    .environmentObject(appState)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("My Applications")
        }
        .task {
            await loadApplications()
        }
        .refreshable {
            await loadApplications()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ApplicationWithdrawn"))) { _ in
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
    
    private var filteredApplications: [Application] {
        switch selectedTab {
        case 0:
            return applications.filter { $0.applicationStatus == .pending }
        case 1:
            return applications.filter { $0.applicationStatus == .accepted }
        case 2:
            return applications.filter { $0.applicationStatus == .completed }
        default:
            return []
        }
    }
    
    private func loadApplications() async {
        guard let studentID = appState.uid else {
            await MainActor.run {
                errorMessage = "You must be logged in to view applications"
            }
            return
        }
        
        print("StudentApplicationsView: Loading applications for student \(studentID)")
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let fetchedApplications = try await ApplicationManager.shared.fetchApplicationsByStudent(studentID: studentID)
            print("StudentApplicationsView: Fetched \(fetchedApplications.count) applications")
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
                print("Error loading applications: \(errorDesc)")
                print("Full error: \(error)")
            }
        }
    }
}

#Preview {
    StudentApplicationsView()
        .environmentObject(AppState())
}
