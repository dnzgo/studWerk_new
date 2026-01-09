//
//  ApplicationCard.swift
//  StudWerk
//
//  Created by Deniz Gözcü on 07.01.26.
//

import SwiftUI

struct ApplicationCard: View {
    let application: Application
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: ApplicationCardViewModel
    
    init(application: Application) {
        self.application = application
        _viewModel = StateObject(wrappedValue: ApplicationCardViewModel(application: application))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.companyName.isEmpty ? "Company" : viewModel.companyName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Text(application.position)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                StatusBadge(status: application.applicationStatus)
            }
            
            HStack {
                Image(systemName: "eurosign.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                
                Text(application.pay)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "calendar")
                    .foregroundColor(.orange)
                    .font(.caption)
                
                Text(application.appliedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if application.applicationStatus == .pending {
                HStack {
                    Button(action: {
                        viewModel.showWithdrawAlert()
                    }) {
                        if viewModel.isWithdrawing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .red))
                        } else {
                            Text("Withdraw")
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                    .disabled(viewModel.isWithdrawing)
                    
                    Spacer()
                    
                    Button("View Details") {
                        Task {
                            await viewModel.loadJobAndShowDetail()
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
            } else if application.applicationStatus == .accepted {
                HStack {
                    Button("Contact Employer") {
                        viewModel.showingEmployerContact = true
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await viewModel.loadJobAndShowDetail()
                        }
                    }) {
                        if viewModel.isLoadingJob {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        } else {
                            Text("View Details")
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                    .disabled(viewModel.isLoadingJob)
                }
            } else {
                HStack {
                    Spacer()
                    
                    Button("View Details") {
                        Task {
                            await viewModel.loadJobAndShowDetail()
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onAppear {
            Task {
                await viewModel.loadCompanyName()
            }
        }
        .sheet(isPresented: $viewModel.showingEmployerContact) {
            NavigationView {
                EmployerContactView(
                    companyName: viewModel.companyName,
                    email: viewModel.employerEmail,
                    phone: viewModel.employerPhone,
                    address: viewModel.employerAddress
                )
            }
        }
        .sheet(isPresented: $viewModel.showingJobDetail) {
            Group {
                if let job = viewModel.job {
                    NavigationView {
                        JobDetailView(job: job)
                            .environmentObject(appState)
                    }
                } else {
                    NavigationView {
                        VStack {
                            ProgressView()
                                .padding()
                            Text("Loading job details...")
                                .foregroundColor(.secondary)
                        }
                        .navigationTitle("Job Details")
                    }
                }
            }
        }
        .alert("Withdraw Application", isPresented: $viewModel.showingWithdrawAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Withdraw", role: .destructive) {
                Task {
                    await viewModel.performWithdraw()
                }
            }
        } message: {
            Text("Are you sure you want to withdraw this application?")
        }
        .alert("Error", isPresented: $viewModel.showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

struct StatusBadge: View {
    let status: ApplicationStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(status.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.color.opacity(0.2))
            .cornerRadius(6)
    }
}

struct JobApplication: Identifiable {
    let id = UUID()
    let company: String
    let position: String
    let pay: String
    let appliedDate: String
    let status: ApplicationStatus
}
