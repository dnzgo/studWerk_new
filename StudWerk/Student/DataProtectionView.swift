//
//  DataProtectionView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 8.01.2026.
//

import SwiftUI

struct DataProtectionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var languageManager = LanguageManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(languageManager.localizedString(for: "dataProtection.title"))
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text(languageManager.localizedString(for: "dataProtection.gdpr"))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(languageManager.localizedString(for: "dataProtection.gdprDesc"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Divider()
                            
                            Text(languageManager.localizedString(for: "dataProtection.yourRights"))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(languageManager.localizedString(for: "dataProtection.yourRightsDesc"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Divider()
                            
                            Text(languageManager.localizedString(for: "dataProtection.dataSecurity"))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(languageManager.localizedString(for: "dataProtection.dataSecurityDesc"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Divider()
                            
                            Text(languageManager.localizedString(for: "dataProtection.dataRetention"))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(languageManager.localizedString(for: "dataProtection.dataRetentionDesc"))
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
            .navigationTitle(languageManager.localizedString(for: "dataProtection.title"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button(languageManager.localizedString(for: "dataProtection.done")) {
                    dismiss()
                }
            )
        }
    }
}
