//
//  JobCard.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI

struct JobCard: View {
    let job: Job
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: JobCardViewModel
    
    init(job: Job) {
        self.job = job
        _viewModel = StateObject(wrappedValue: JobCardViewModel(job: job))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.position)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Spacer()
            }
            
            HStack {
                Image(systemName: "eurosign.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                
                Text(job.pay)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "clock.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                
                Text(job.dateString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Text(job.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(job.distance)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Button("View Details") {
                    viewModel.showingJobDetail = true
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                
                Spacer()
                
                if viewModel.hasApplied {
                    Button("Applied") {
                        // Already applied
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .cornerRadius(6)
                    .disabled(true)
                } else {
                    Button(action: {
                        Task {
                            await viewModel.quickApply()
                        }
                    }) {
                        if viewModel.isApplying {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Quick Apply")
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(viewModel.isApplying ? Color.blue.opacity(0.6) : Color.blue)
                    .cornerRadius(6)
                    .disabled(viewModel.isApplying || viewModel.isCheckingApplication)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onAppear {
            if let studentID = appState.uid {
                viewModel.studentID = studentID
                Task {
                    await viewModel.checkApplicationStatus()
                }
            }
        }
        .sheet(isPresented: $viewModel.showingJobDetail) {
            NavigationView {
                JobDetailView(job: job)
                    .environmentObject(appState)
            }
        }
        .alert("Success", isPresented: $viewModel.showingSuccessAlert) {
            Button("OK") { }
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
