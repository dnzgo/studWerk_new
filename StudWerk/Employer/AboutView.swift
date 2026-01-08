//
//  AboutView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 8.01.2026.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(spacing: 16) {
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("StudWerk")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About StudWerk")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("StudWerk is a platform that connects students with employers for part-time job opportunities. Employers can post jobs and students can apply, making it easy to find work that fits around studies.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How to Use")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("1. Post Jobs")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Create job postings with details about the position, payment, and schedule.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("2. Review Applications")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("View and manage applications from students who are interested in your jobs.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("3. Contact Students")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Get in touch with students directly through the application details.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("4. Manage Profile")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Keep your company information and settings up to date.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Created By")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("StudWerk Development Team")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
    }
}
