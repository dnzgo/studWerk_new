//
//  StudentEditInfoView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 8.01.2026.
//

import SwiftUI

struct StudentEditInfoView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var phone: String
    @State private var address: String
    @State private var iban: String
    @State private var isUpdating = false
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    init(name: String, phone: String, address: String, iban: String) {
        _name = State(initialValue: name)
        _phone = State(initialValue: phone)
        _address = State(initialValue: address)
        _iban = State(initialValue: iban)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Edit Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Name *")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                TextField("Enter name", text: $name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .textInputAutocapitalization(.words)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Phone Number *")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                TextField("Enter phone number", text: $phone)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.phonePad)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Address *")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                TextField("Enter address", text: $address)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .textInputAutocapitalization(.words)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("IBAN *")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                TextField("Enter IBAN", text: $iban)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.allCharacters)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Button(action: updateProfile) {
                        HStack {
                            if isUpdating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Save Changes")
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isFormValid && !isUpdating ? Color.blue : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid || isUpdating)
                }
                .padding()
            }
            .navigationTitle("Edit Info")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    updateProfile()
                }
                .disabled(!isFormValid || isUpdating)
            )
            .alert("Success", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Profile updated successfully")
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !phone.isEmpty && !address.isEmpty && !iban.isEmpty
    }
    
    private func updateProfile() {
        guard let studentID = appState.uid else {
            errorMessage = "You must be logged in"
            showingErrorAlert = true
            return
        }
        
        isUpdating = true
        
        Task {
            do {
                try await StudentManager.shared.updateStudentProfile(
                    studentID: studentID,
                    name: name,
                    phone: phone,
                    address: address,
                    iban: iban
                )
                
                await MainActor.run {
                    isUpdating = false
                    showingSuccessAlert = true
                    // Post notification to reload profile
                    NotificationCenter.default.post(name: NSNotification.Name("StudentProfileUpdated"), object: nil)
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
