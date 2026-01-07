//
//  EmployerProfileView.swift
//  StudWerk
//
//  Created by Deniz Gözcü on 5.1.2026.
//

import SwiftUI

struct EmployerProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var employerName = "" // TODO: Fetch from user profile
    @State private var isCompany = false
    @State private var companyName = "" // TODO: Fetch from user profile
    @State private var industry = "" // TODO: Fetch from user profile
    @State private var companySize = "" // TODO: Fetch from user profile
    @State private var location = "" // TODO: Fetch from user profile
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
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
                            Text(isCompany ? (companyName.isEmpty ? "Company" : companyName) : (employerName.isEmpty ? "Employer" : employerName))
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(isCompany ? (industry.isEmpty ? "Company" : industry) : "Individual Employer")
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
                            Text("Individual Employer")
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
                                Text(isCompany ? companyName : employerName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            if isCompany {
                                HStack {
                                    Text("Industry")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(industry)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                
                                HStack {
                                    Text("Company Size")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(companySize)
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
            .navigationTitle("Profile")
        }
        .sheet(isPresented: $showingSettings) {
            EmployerSettingsView()
        }
    }
}


struct EmployerSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Account") {
                    SettingsRow(icon: "building.2.circle", title: "Company Information", color: .blue)
                    SettingsRow(icon: "lock.circle", title: "Change Password", color: .green)
                    SettingsRow(icon: "envelope.circle", title: "Email Settings", color: .orange)
                }
                
                Section("Notifications") {
                    SettingsRow(icon: "bell.circle", title: "Push Notifications", color: .red)
                    SettingsRow(icon: "mail.circle", title: "Email Notifications", color: .blue)
                }
                
                Section("Support") {
                    SettingsRow(icon: "questionmark.circle", title: "Help & Support", color: .blue)
                    SettingsRow(icon: "info.circle", title: "About", color: .gray)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    EmployerProfileView()
}
