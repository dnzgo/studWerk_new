//
//  PaymentDetailsView.swift
//  StudWerk
//
//  Created by Deniz Gözcü on 07.01.26.
//

import SwiftUI

struct PaymentDetailsView: View {
    let iban: String
    let currentEarnings: Double
    let monthlyLimit: Double
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var languageManager = LanguageManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "eurosign.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text(languageManager.localizedString(for: "paymentDetails.paymentReady"))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(languageManager.localizedString(for: "paymentDetails.accountSetup"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(languageManager.localizedString(for: "paymentDetails.paymentInformation"))
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text(languageManager.localizedString(for: "paymentDetails.iban"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(iban)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text(languageManager.localizedString(for: "paymentDetails.currentEarnings"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("€\(String(format: "%.0f", currentEarnings))")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text(languageManager.localizedString(for: "paymentDetails.monthlyLimit"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("€\(String(format: "%.0f", monthlyLimit))")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(languageManager.localizedString(for: "paymentDetails.recentPayments"))
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        PaymentRow(description: "Garden Cleaning", amount: 50.0, date: "Today")
                        PaymentRow(description: "Wall Painting", amount: 120.0, date: "Yesterday")
                        PaymentRow(description: "Office Cleaning", amount: 80.0, date: "3 days ago")
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .navigationTitle(languageManager.localizedString(for: "paymentDetails.title"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button(languageManager.localizedString(for: "paymentDetails.done")) {
                    dismiss()
                }
            )
        }
    }
}

struct PaymentRow: View {
    let description: String
    let amount: Double
    let date: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("€\(String(format: "%.0f", amount))")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
