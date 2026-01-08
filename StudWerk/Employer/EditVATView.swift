//
//  EditVATView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 8.01.2026.
//

import SwiftUI

struct EditVATView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var vatID: String
    @State private var isUpdating = false
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    init(vatID: String) {
        _vatID = State(initialValue: vatID)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("VAT Number")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("VAT ID")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextField("Enter VAT number", text: $vatID)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textInputAutocapitalization(.characters)
                            
                            Text("Leave empty if you are an individual employer")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Button(action: updateVAT) {
                        HStack {
                            if isUpdating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Save VAT Number")
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(!isUpdating ? Color.blue : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(isUpdating)
                }
                .padding()
            }
            .navigationTitle("VAT Number")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    updateVAT()
                }
                .disabled(isUpdating)
            )
            .alert("Success", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("VAT number updated successfully")
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func updateVAT() {
        guard let employerID = appState.uid else {
            errorMessage = "You must be logged in"
            showingErrorAlert = true
            return
        }
        
        isUpdating = true
        
        Task {
            do {
                try await EmployerManager.shared.updateVATID(
                    employerID: employerID,
                    vatID: vatID.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                
                await MainActor.run {
                    isUpdating = false
                    showingSuccessAlert = true
                    // Post notification to reload profile
                    NotificationCenter.default.post(name: NSNotification.Name("EmployerProfileUpdated"), object: nil)
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
