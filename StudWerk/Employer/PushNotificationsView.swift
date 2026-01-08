//
//  PushNoficitationView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 8.01.2026.
//

import SwiftUI

struct PushNotificationsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var pushNotificationsEnabled = false
    @State private var isLoading = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Push Notifications")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Enable Notifications")
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Toggle("", isOn: $pushNotificationsEnabled)
                                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                                    .onChange(of: pushNotificationsEnabled) { newValue in
                                        updateNotificationSettings(enabled: newValue)
                                    }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            Text("When enabled, you will receive notifications when a student applies to your job postings.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Push Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
            .onAppear {
                Task {
                    await loadNotificationSettings()
                }
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func loadNotificationSettings() async {
        guard let employerID = appState.uid else { return }
        
        isLoading = true
        do {
            let enabled = try await EmployerManager.shared.fetchPushNotificationsEnabled(employerID: employerID)
            await MainActor.run {
                pushNotificationsEnabled = enabled
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Failed to load notification settings: \(error.localizedDescription)"
                showingErrorAlert = true
            }
        }
    }
    
    private func updateNotificationSettings(enabled: Bool) {
        guard let employerID = appState.uid else { return }
        
        Task {
            do {
                try await EmployerManager.shared.updatePushNotificationsEnabled(
                    employerID: employerID,
                    enabled: enabled
                )
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to update notification settings: \(error.localizedDescription)"
                    showingErrorAlert = true
                    // Revert toggle
                    pushNotificationsEnabled = !enabled
                }
            }
        }
    }
}
