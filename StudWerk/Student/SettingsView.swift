//
//  SettingsView.swift
//  StudWerk
//
//  Created by Deniz Gözcü on 07.01.26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Account") {
                    SettingsRow(icon: "person.circle", title: "Personal Information", color: .blue)
                    SettingsRow(icon: "lock.circle", title: "Change Password", color: .green)
                    SettingsRow(icon: "envelope.circle", title: "Email Settings", color: .orange)
                }
                
                Section("Notifications") {
                    SettingsRow(icon: "bell.circle", title: "Push Notifications", color: .red)
                    SettingsRow(icon: "mail.circle", title: "Email Notifications", color: .blue)
                }
                
                Section("Privacy") {
                    SettingsRow(icon: "eye.circle", title: "Privacy Settings", color: .purple)
                    SettingsRow(icon: "hand.raised.circle", title: "Data Protection", color: .gray)
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
