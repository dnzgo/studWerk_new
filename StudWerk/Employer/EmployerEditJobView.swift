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
    
    @State private var jobTitle: String
    @State private var jobDescription: String
    @State private var payment: String
    @State private var selectedDate: Date
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var selectedCategory: String
    @State private var location: String
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var isUpdating = false
    
    let categories = ["General", "Technology", "Retail", "Food Service", "Marketing", "Administration", "Customer Service", "Other"]
    
    init(job: Job) {
        self.job = job
        _jobTitle = State(initialValue: job.jobTitle)
        _jobDescription = State(initialValue: job.jobDescription)
        _payment = State(initialValue: job.payment)
        _selectedDate = State(initialValue: job.date)
        _startTime = State(initialValue: job.startTime)
        _endTime = State(initialValue: job.endTime)
        _selectedCategory = State(initialValue: job.category)
        _location = State(initialValue: job.location)
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
                            
                            TextField("e.g., Software Developer Intern", text: $jobTitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category *")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(categories, id: \.self) { category in
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
                            
                            TextEditor(text: $jobDescription)
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
                                
                                TextField("50.00", text: $payment)
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
                            
                            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
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
                                
                                DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("End Time *")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                DatePicker("End", selection: $endTime, displayedComponents: .hourAndMinute)
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
                            
                            TextField("e.g., Musterstraße 123, 10115 Berlin", text: $location)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
                
                // Update Job Button
                Button(action: {
                    updateJob()
                }) {
                    HStack {
                        if isUpdating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(isUpdating ? "Updating..." : "Update Job")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isFormValid && !isUpdating ? Color.blue : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(!isFormValid || isUpdating)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
        }
        .navigationTitle("Edit Job")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Job Updated!", isPresented: $showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your job has been successfully updated.")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var isFormValid: Bool {
        !jobTitle.isEmpty &&
        !jobDescription.isEmpty &&
        !payment.isEmpty &&
        !location.isEmpty
    }
    
    private func updateJob() {
        isUpdating = true
        
        Task {
            do {
                try await JobManager.shared.updateJob(
                    jobID: job.id,
                    jobTitle: jobTitle,
                    jobDescription: jobDescription,
                    payment: payment,
                    date: selectedDate,
                    startTime: startTime,
                    endTime: endTime,
                    category: selectedCategory,
                    location: location
                )
                
                await MainActor.run {
                    isUpdating = false
                    showingSuccessAlert = true
                    // Post notification to reload jobs
                    NotificationCenter.default.post(name: NSNotification.Name("JobStatusUpdated"), object: nil)
                }
            } catch {
                await MainActor.run {
                    isUpdating = false
                    errorMessage = error.localizedDescription
                    showingErrorAlert = true
                }
            }
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

