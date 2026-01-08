//
//  HelpSupportView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 8.01.2026.
//

import SwiftUI

struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Support Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Need Help?")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("If you have any questions or need assistance, please contact our support team.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Contact Support")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.blue)
                                Text("support@studwerk.com")
                                    .font(.subheadline)
                            }
                            
                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.blue)
                                Text("+49 (0) 123 456 789")
                                    .font(.subheadline)
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Common Questions")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("• How do I post a job?")
                            Text("• How do I review applications?")
                            Text("• How do I contact students?")
                            Text("• How do I manage my profile?")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
    }
}
