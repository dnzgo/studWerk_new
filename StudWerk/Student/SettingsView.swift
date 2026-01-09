//
//  SettingsView.swift
//  StudWerk
//
//  Created by Deniz Gözcü on 07.01.26.
//

import SwiftUI
import FirebaseFirestore
import Combine

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @StateObject private var languageManager = LanguageManager.shared
    
    @State private var showingEditInfo = false
    @State private var showingPushNotifications = false
    @State private var showingPrivacySettings = false
    @State private var showingDataProtection = false
    @State private var showingHelpSupport = false
    @State private var showingAbout = false
    
    @State private var currentName = ""
    @State private var currentPhone = ""
    @State private var currentAddress = ""
    @State private var currentIBAN = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(languageManager.localizedString(for: "settings.language")) {
                    Picker(languageManager.localizedString(for: "settings.language"), selection: $languageManager.currentLanguage) {
                        ForEach(AppLanguage.allCases, id: \.self) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(languageManager.localizedString(for: "settings.account")) {
                    Button(action: {
                        loadCurrentData()
                        showingEditInfo = true
                    }) {
                        SettingsRow(
                            icon: "person.circle",
                            title: languageManager.localizedString(for: "settings.updateInfo"),
                            color: .blue
                        )
                    }
                    
                    SettingsRow(
                        icon: "lock.circle",
                        title: languageManager.localizedString(for: "settings.changePassword"),
                        color: .green
                    )
                }
                
                Section(languageManager.localizedString(for: "settings.notifications")) {
                    Button(action: {
                        showingPushNotifications = true
                    }) {
                        SettingsRow(
                            icon: "bell.circle",
                            title: languageManager.localizedString(for: "settings.pushNotifications"),
                            color: .red
                        )
                    }
                    
                    SettingsRow(
                        icon: "mail.circle",
                        title: languageManager.localizedString(for: "settings.emailNotifications"),
                        color: .blue
                    )
                }
                
                Section(languageManager.localizedString(for: "settings.privacy")) {
                    Button(action: {
                        showingPrivacySettings = true
                    }) {
                        SettingsRow(
                            icon: "eye.circle",
                            title: languageManager.localizedString(for: "settings.privacyPolicy"),
                            color: .purple
                        )
                    }
                    
                    Button(action: {
                        showingDataProtection = true
                    }) {
                        SettingsRow(
                            icon: "hand.raised.circle",
                            title: languageManager.localizedString(for: "settings.dataProtection"),
                            color: .gray
                        )
                    }
                }
                
                Section(languageManager.localizedString(for: "settings.support")) {
                    Button(action: {
                        showingHelpSupport = true
                    }) {
                        SettingsRow(
                            icon: "questionmark.circle",
                            title: languageManager.localizedString(for: "settings.helpSupport"),
                            color: .blue
                        )
                    }
                    
                    Button(action: {
                        showingAbout = true
                    }) {
                        SettingsRow(
                            icon: "info.circle",
                            title: languageManager.localizedString(for: "settings.about"),
                            color: .gray
                        )
                    }
                }
                
                Section {
                    Button(action: {
                        logout()
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            
                            Text(languageManager.localizedString(for: "settings.logOut"))
                                .font(.subheadline)
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(languageManager.localizedString(for: "settings.title"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button(languageManager.localizedString(for: "settings.done")) {
                    dismiss()
                }
            )
            .sheet(isPresented: $showingEditInfo) {
                StudentEditInfoView(name: currentName, phone: currentPhone, address: currentAddress, iban: currentIBAN)
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showingPushNotifications) {
                StudentPushNotificationsView()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showingPrivacySettings) {
                PrivacySettingsView()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showingDataProtection) {
                DataProtectionView()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showingHelpSupport) {
                HelpSupportView()
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .onAppear {
                loadCurrentData()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("StudentProfileUpdated"))) { _ in
                loadCurrentData()
            }
        }
    }
    
    private func loadCurrentData() {
        guard let studentID = appState.uid else { return }
        
        Task {
            do {
                let db = Firestore.firestore()
                let studentDoc = try await db.collection("students").document(studentID).getDocument()
                
                if let data = studentDoc.data() {
                    await MainActor.run {
                        currentName = data["name"] as? String ?? ""
                        currentPhone = data["phone"] as? String ?? ""
                        currentAddress = data["address"] as? String ?? ""
                        currentIBAN = data["iban"] as? String ?? ""
                    }
                }
            } catch {
                print("Error loading current data: \(error.localizedDescription)")
            }
        }
    }
    
    private func logout() {
        do {
            try AuthManager.shared.logout()
            appState.logout()
            dismiss()
        } catch {
            print("Error logging out: \(error.localizedDescription)")
            // Still logout from app state even if Firebase logout fails
            appState.logout()
            dismiss()
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}
