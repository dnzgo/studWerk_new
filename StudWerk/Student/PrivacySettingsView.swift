//
//  PrivacySettingsView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 8.01.2026.
//

import SwiftUI

struct PrivacySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var languageManager = LanguageManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(languageManager.localizedString(for: "privacy.policy"))
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text(languageManager.localizedString(for: "privacy.policy"))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(languageManager.localizedString(for: "privacy.intro"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Divider()
                            
                            Text(languageManager.localizedString(for: "privacy.infoWeCollect"))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(languageManager.localizedString(for: "privacy.infoWeCollectDesc"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Divider()
                            
                            Text(languageManager.localizedString(for: "privacy.howWeUse"))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(languageManager.localizedString(for: "privacy.howWeUseDesc"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Divider()
                            
                            Text(languageManager.localizedString(for: "privacy.dataProtection"))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(languageManager.localizedString(for: "privacy.dataProtectionDesc"))
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
            .navigationTitle(languageManager.localizedString(for: "privacy.title"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button(languageManager.localizedString(for: "privacy.done")) {
                    dismiss()
                }
            )
        }
    }
}
