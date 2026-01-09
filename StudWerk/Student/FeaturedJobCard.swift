//
//  FeaturedJobCard.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI

struct FeaturedJobCard: View {
    let job: Job
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: FeaturedJobCardViewModel
    
    init(job: Job) {
        self.job = job
        _viewModel = StateObject(wrappedValue: FeaturedJobCardViewModel(job: job))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.companyName.isEmpty ? "Company" : viewModel.companyName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
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
                
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Text(job.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(job.dateString)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if viewModel.hasApplied {
                Button("Applied") {
                    // Already applied
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(Color.green)
                .cornerRadius(8)
                .disabled(true)
            } else {
                Button(action: {
                    viewModel.showingJobDetail = true
                }) {
                    Text("Apply Now")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(Color.blue)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .frame(width: 280)
        .onAppear {
            if let studentID = appState.uid {
                viewModel.studentID = studentID
            Task {
                    await viewModel.checkApplicationStatus()
                    await viewModel.loadCompanyName()
                }
            }
        }
        .sheet(isPresented: $viewModel.showingJobDetail) {
            NavigationView {
                JobDetailView(job: job)
                    .environmentObject(appState)
            }
        }
    }
}

