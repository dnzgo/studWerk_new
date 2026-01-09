//
//  PrivacySettingsView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 8.01.2026.
//

import SwiftUI

struct PrivacySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Privacy Policy")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Privacy Policy")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("By using StudWerk, you agree to how we collect, use, and protect your personal information. This privacy policy explains our practices regarding data collection and usage.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Divider()
                            
                            Text("Information We Collect")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("We collect information that you provide directly to us, including your name, email address, phone number, and other profile information necessary for the platform to function.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Divider()
                            
                            Text("How We Use Your Information")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("We use the information we collect to provide, maintain, and improve our services, process transactions, send notifications, and communicate with you about your account.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Divider()
                            
                            Text("Data Protection")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Privacy Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
    }
}
