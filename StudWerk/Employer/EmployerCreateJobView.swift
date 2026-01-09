//
//  EmployerCreate.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI

struct EmployerCreateJobView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = EmployerCreateJobViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Create New Job")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Fill in the details to post your job")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Job Details Section
                    VStack(alignment: .leading, spacing: 20) {
                        
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
                    
                    // Create Job Button
                    Button(action: {
                        Task {
                            await viewModel.createJob()
                        }
                    }) {
                        HStack {
                            if viewModel.isCreating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text(viewModel.isCreating ? "Creating..." : "Create Job")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(viewModel.isFormValid && !viewModel.isCreating ? Color.blue : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isCreating)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .task {
            if let employerID = appState.uid {
                viewModel.employerID = employerID
            }
        }
        .alert("Job Created!", isPresented: $viewModel.showingSuccessAlert) {
            Button("OK") {
                viewModel.resetForm()
            }
        } message: {
            Text("Your job has been successfully posted and is now visible to students.")
        }
        .alert("Error", isPresented: $viewModel.showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

#Preview {
    EmployerCreateJobView()
        .environmentObject(AppState())
}

