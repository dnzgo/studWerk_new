//
//  EmployerSettingsView.swift
//  StudWerk
//
//  Created by Deniz Gözcü on 09.01.26.
//

import SwiftUI
import FirebaseFirestore

struct EmployerSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    
    @State private var showingEditInfo = false
    @State private var showingEditVAT = false
    @State private var showingPushNotifications = false
    @State private var showingHelpSupport = false
    @State private var showingAbout = false
    
    @State private var currentName = ""
    @State private var currentPhone = ""
    @State private var currentAddress = ""
    @State private var currentVATID = ""
    
    var body: some View {
        NavigationView {
            List {
                Section("Account") {
                    Button(action: {
                        loadCurrentData()
                        showingEditInfo = true
                    }) {
                        SettingsRow(icon: "person.circle", title: "Edit Info", color: .blue)
                    }
                    
                    SettingsRow(icon: "lock.circle", title: "Change Password", color: .green)
                    
                    Button(action: {
                        loadCurrentData()
                        showingEditVAT = true
                    }) {
                        SettingsRow(icon: "number.circle", title: "Add VAT Number", color: .green)
                    }
                }
                
                Section("Notifications") {
                    Button(action: {
                        showingPushNotifications = true
                    }) {
                        SettingsRow(icon: "bell.circle", title: "Push Notifications", color: .red)
                    }
                    
                    SettingsRow(icon: "envelope.circle", title: "Email Notifications", color: .blue)
                }
                
                Section("Support") {
                    Button(action: {
                        showingHelpSupport = true
                    }) {
                        SettingsRow(icon: "questionmark.circle", title: "Help & Support", color: .blue)
                    }
                    
                    Button(action: {
                        showingAbout = true
                    }) {
                        SettingsRow(icon: "info.circle", title: "About", color: .gray)
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
                            
                            Text("Log Out")
                                .font(.subheadline)
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
            .sheet(isPresented: $showingEditInfo) {
                EditInfoView(name: currentName, phone: currentPhone, address: currentAddress)
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showingEditVAT) {
                EditVATView(vatID: currentVATID)
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showingPushNotifications) {
                PushNotificationsView()
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
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("EmployerProfileUpdated"))) { _ in
                loadCurrentData()
            }
        }
    }
    
    private func loadCurrentData() {
        guard let employerID = appState.uid else { return }
        
        Task {
            do {
                let db = Firestore.firestore()
                let employerDoc = try await db.collection("employers").document(employerID).getDocument()
                
                if let data = employerDoc.data() {
                    await MainActor.run {
                        currentName = data["name"] as? String ?? ""
                        currentPhone = data["phone"] as? String ?? ""
                        currentAddress = data["address"] as? String ?? ""
                        currentVATID = data["vatID"] as? String ?? ""
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
