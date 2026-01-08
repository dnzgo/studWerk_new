//
//  EmployerProfileView.swift
//  StudWerk
//
//  Created by Deniz Gözcü on 5.1.2026.
//

import SwiftUI
import FirebaseFirestore

struct EmployerProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var isCompany = false
    @State private var name = ""
    @State private var location = ""
    @State private var showingSettings = false
    @State private var isLoading = false
    @State private var vatID: String = ""
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                if isLoading {
                    ProgressView("Loading profile...")
                        .padding(.top, 100)
                } else {
                    VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Profile Picture
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: isCompany ? "building.2.fill" : "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                            )
                        
                        VStack(spacing: 4) {
                            Text(name.isEmpty ? (isCompany ? "Company" : "Employer") : name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(isCompany ? "Company" : "Individual Employer")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(location.isEmpty ? "" : location)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Employer Type Toggle
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Employer Type")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Text(isCompany ? "Company" : "Individual")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Toggle("", isOn: $isCompany)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Employer Information
                    VStack(alignment: .leading, spacing: 16) {
                        Text(isCompany ? "Company Information" : "Personal Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text(isCompany ? "Company Name" : "Name")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            if isCompany {
                                HStack {
                                    Text("VAT")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(vatID.isEmpty ? "Not set" : vatID)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                            }
                            
                            HStack {
                                Text("Location")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(location)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Settings Button
                    Button(action: {
                        showingSettings = true
                    }) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.blue)
                            
                            Text("Settings")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Profile")
        }
        .sheet(isPresented: $showingSettings) {
            EmployerSettingsView()
        }
        .onAppear {
            Task {
                await loadProfileData()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("EmployerProfileUpdated"))) { _ in
            Task {
                await loadProfileData()
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func loadProfileData() async {
        guard let employerID = appState.uid else {
            await MainActor.run {
                errorMessage = "You must be logged in to view profile"
            }
            return
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let db = Firestore.firestore()
            
            // Load employer data from employers collection
            let employerDoc = try await db.collection("employers").document(employerID).getDocument()
            
            if let data = employerDoc.data() {
                await MainActor.run {
                    // Name is stored as "name" in Firestore
                    name = data["name"] as? String ?? ""
                    // Address is stored as "address" in Firestore
                    location = data["address"] as? String ?? ""
                    // VAT ID is stored as "vatID" in Firestore (empty string if not set or null)
                    vatID = data["vatID"] as? String ?? ""
                    // Set isCompany based on whether vatID exists and is not empty
                    isCompany = !vatID.isEmpty
                }
            }
            
            await MainActor.run {
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Failed to load profile: \(error.localizedDescription)"
                print("Error loading profile: \(error.localizedDescription)")
            }
        }
    }
}


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
                    
                    SettingsRow(icon: "envelope.circle", title: "Email Settings", color: .orange)
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
}

#Preview {
    EmployerProfileView()
}
