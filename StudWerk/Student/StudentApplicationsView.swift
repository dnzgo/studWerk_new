//
//  StudentApplicationsView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI

struct StudentApplicationsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = StudentApplicationsViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("Status", selection: Binding(
                    get: { viewModel.selectedTab.rawValue },
                    set: { viewModel.selectedTab = ApplicationTab(rawValue: $0) ?? .pending }
                )) {
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
                        if viewModel.isLoading {
                            ProgressView()
                                .padding(.top, 40)
                        } else if viewModel.filteredApplications.isEmpty {
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
                            ForEach(viewModel.filteredApplications, id: \.id) { application in
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
            if let studentID = appState.uid {
                viewModel.studentID = studentID
                await viewModel.loadApplications()
            }
        }
        .refreshable {
            await viewModel.loadApplications()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ApplicationWithdrawn"))) { _ in
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
    StudentApplicationsView()
        .environmentObject(AppState())
}
