//
//  EmployerCreate.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI

struct EmployerCreateJobView: View {
    @State private var jobTitle = ""
    @State private var jobDescription = ""
    @State private var payment = ""
    @State private var selectedDate = Date()
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var selectedCategory = "General"
    @State private var location = ""
    @State private var showingSuccessAlert = false
    
    let categories = ["General", "Technology", "Retail", "Food Service", "Marketing", "Administration", "Customer Service", "Other"]
    
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
                    
                    // Create Job Button
                    Button(action: {
                        createJob()
                    }) {
                        Text("Create Job")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(isFormValid ? Color.blue : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!isFormValid)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Create Job")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Job Created!", isPresented: $showingSuccessAlert) {
            Button("OK") {
                resetForm()
            }
        } message: {
            Text("Your job has been successfully posted and is now visible to students.")
        }
    }
    
    private var isFormValid: Bool {
        !jobTitle.isEmpty &&
        !jobDescription.isEmpty &&
        !payment.isEmpty &&
        !location.isEmpty
    }
    
    private func createJob() {
        // Handle job creation logic here
        showingSuccessAlert = true
    }
    
    private func resetForm() {
        jobTitle = ""
        jobDescription = ""
        payment = ""
        selectedDate = Date()
        startTime = Date()
        endTime = Date()
        selectedCategory = "General"
        location = ""
    }
}

#Preview {
    EmployerCreateJobView()
}
