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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "eurosign.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Payment Ready")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Your account is set up for receiving payments")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Payment Information")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("IBAN")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(iban)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Current Earnings")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("€\(String(format: "%.0f", currentEarnings))")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Monthly Limit")
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
                    Text("Recent Payments")
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
            .navigationTitle("Payment Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
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
