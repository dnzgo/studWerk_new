//
//  DataProtectionView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 8.01.2026.
//

import SwiftUI

struct DataProtectionView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Data Protection")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("GDPR Compliance")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("We are committed to protecting your personal data in accordance with the General Data Protection Regulation (GDPR). This section explains your rights and how we handle your data.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Divider()
                            
                            Text("Your Rights")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("You have the right to access, rectify, erase, restrict processing, object to processing, and data portability regarding your personal data. You can exercise these rights by contacting us.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Divider()
                            
                            Text("Data Security")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("We implement technical and organizational measures to ensure a level of security appropriate to the risk, including encryption, access controls, and regular security assessments.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Divider()
                            
                            Text("Data Retention")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("We retain your personal data only for as long as necessary to fulfill the purposes for which it was collected, or as required by law.")
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
            .navigationTitle("Data Protection")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
    }
}
