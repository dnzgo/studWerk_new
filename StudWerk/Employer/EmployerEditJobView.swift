//
//  EmployerEditJobView.swift
//  StudWerk
//
//  Created on 07.01.26.
//

import SwiftUI

struct EmployerEditJobView: View {
    let job: Job
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: EmployerEditJobViewModel
    
    init(job: Job) {
        self.job = job
        _viewModel = StateObject(wrappedValue: EmployerEditJobViewModel(job: job))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Edit Job")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Update the job details")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Job Details Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Job Details")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 16) {
                        // Job Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Job Title *")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextField("e.g., Software Developer Intern", text: $viewModel.jobTitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category *")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Picker("Category", selection: $viewModel.selectedCategory) {
                                ForEach(viewModel.categories, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        // Job Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Job Description *")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextEditor(text: $viewModel.jobDescription)
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                }
                
                // Payment & Schedule Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Payment & Schedule")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 16) {
                        // Payment
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fixed Payment *")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack {
                                Text("€")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                
                                TextField("50.00", text: $viewModel.payment)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                            }
                            
                            Text("One-time payment for the complete job")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Job Date *")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            DatePicker("Select Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        // Time Range
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Start Time *")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                DatePicker("Start", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("End Time *")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                DatePicker("End", selection: $viewModel.endTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // Location Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Location")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 16) {
                        // Location Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Work Location *")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextField("e.g., Musterstraße 123, 10115 Berlin", text: $viewModel.location)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
                
                // Update Job Button
                Button(action: {
                    Task {
                        await viewModel.updateJob()
                    }
                }) {
                    HStack {
                        if viewModel.isUpdating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(viewModel.isUpdating ? "Updating..." : "Update Job")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(viewModel.isFormValid && !viewModel.isUpdating && !viewModel.isDeleting ? Color.blue : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(!viewModel.isFormValid || viewModel.isUpdating || viewModel.isDeleting)
                .padding(.horizontal, 20)
                
                // Delete Job Button
                Button(action: {
                    viewModel.showingDeleteConfirmation = true
                }) {
                    HStack {
                        if viewModel.isDeleting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(viewModel.isDeleting ? "Deleting..." : "Delete Job")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(viewModel.isDeleting ? Color.gray : Color.red)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isUpdating || viewModel.isDeleting)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
        }
        .navigationTitle("Edit Job")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Job Updated!", isPresented: $viewModel.showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your job has been successfully updated.")
        }
        .alert("Error", isPresented: $viewModel.showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Delete Job", isPresented: $viewModel.showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteJob()
                }
            }
        } message: {
            Text("Are you sure you want to delete this job? This will also delete all related applications. This action cannot be undone.")
        }
        .alert("Job Deleted", isPresented: $viewModel.showingDeleteSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("The job and all related applications have been deleted.")
        }
    }
}

#Preview {
    NavigationView {
        EmployerEditJobView(job: Job(
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

