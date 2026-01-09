//
//  JobDetailView.swift
//  StudWerk
//
//  Created on 07.01.26.
//

import SwiftUI

struct JobDetailView: View {
    let job: Job
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: JobDetailViewModel
    
    init(job: Job) {
        self.job = job
        _viewModel = StateObject(wrappedValue: JobDetailViewModel(job: job))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.companyName.isEmpty ? "Company" : viewModel.companyName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text(job.position)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Category badge
                    Text(job.category)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
                
                Divider()
                
                // Job Details
                VStack(alignment: .leading, spacing: 16) {
                    // Payment
                    HStack {
                        Image(systemName: "eurosign.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Payment")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(job.pay)
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    // Date and Time
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.orange)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Date & Time")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(job.dateString)
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    // Location
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Location")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(job.location)
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                Divider()
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(job.description)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle("Job Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.isCheckingApplication {
                    ProgressView()
                } else if viewModel.hasApplied {
                    Button("Applied") {
                        // Already applied
                    }
                    .disabled(true)
                    .foregroundColor(.green)
                } else {
                    Button(action: {
                        Task {
                            await viewModel.applyToJob()
                        }
                    }) {
                        if viewModel.isApplying {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Apply")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(viewModel.isApplying)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(viewModel.isApplying ? Color.blue.opacity(0.6) : Color.blue)
                    .cornerRadius(8)
                }
            }
        }
        .task {
            if let studentID = appState.uid {
                viewModel.studentID = studentID
                await viewModel.checkApplicationStatus()
                await viewModel.loadCompanyName()
            }
        }
        .alert("Success", isPresented: $viewModel.showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your application has been submitted successfully!")
        }
        .alert("Error", isPresented: $viewModel.showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

#Preview {
    NavigationView {
        JobDetailView(job: Job(
            id: "1",
            employerID: "emp1",
            jobTitle: "Software Developer",
            jobDescription: "We are looking for a software developer...",
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

