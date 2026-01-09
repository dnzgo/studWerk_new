//
//  StudentPushNotificationsView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 8.01.2026.
//

import SwiftUI

struct StudentPushNotificationsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var languageManager = LanguageManager.shared
    
    @State private var pushNotificationsEnabled = false
    @State private var isLoading = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(languageManager.localizedString(for: "pushNotifications.title"))
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(languageManager.localizedString(for: "pushNotifications.enable"))
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
                            
                            Text(languageManager.localizedString(for: "pushNotifications.description"))
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
            .navigationTitle(languageManager.localizedString(for: "pushNotifications.title"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button(languageManager.localizedString(for: "pushNotifications.done")) {
                    dismiss()
                }
            )
            .onAppear {
                Task {
                    await loadNotificationSettings()
                }
            }
            .alert(languageManager.localizedString(for: "pushNotifications.error"), isPresented: $showingErrorAlert) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func loadNotificationSettings() async {
        guard let userID = appState.uid else { return }
        
        isLoading = true
        do {
            let enabled = try await UserManager.shared.fetchPushNotificationsEnabled(userID: userID)
            await MainActor.run {
                pushNotificationsEnabled = enabled
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                let errorFormat = languageManager.localizedString(for: "pushNotifications.loadError")
                errorMessage = String(format: errorFormat, error.localizedDescription)
                showingErrorAlert = true
            }
        }
    }
    
    private func updateNotificationSettings(enabled: Bool) {
        guard let userID = appState.uid else { return }
        
        Task {
            do {
                try await UserManager.shared.updatePushNotificationsEnabled(
                    userID: userID,
                    enabled: enabled
                )
            } catch {
                await MainActor.run {
                    let errorFormat = languageManager.localizedString(for: "pushNotifications.updateError")
                    errorMessage = String(format: errorFormat, error.localizedDescription)
                    showingErrorAlert = true
                    // Revert toggle
                    pushNotificationsEnabled = !enabled
                }
            }
        }
    }
}
