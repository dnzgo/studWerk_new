//
//  StudentProfileView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI

struct StudentProfileView: View {
    @State private var workLimit = 20
    @State private var address = "Musterstraße 123, 10115 Berlin"
    @State private var university = "Humboldt University Berlin"
    @State private var studyProgram = "Computer Science"
    @State private var semester = 3
    @State private var showingSettings = false
    @State private var currentEarnings = 450.0
    @State private var monthlyLimit = 1100.0
    @State private var iban = "DE89 3704 0044 0532 0130 00"
    @State private var showingPaymentDetails = false
    
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
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                            )
                        
                        VStack(spacing: 4) {
                            Text("Max Mustermann")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Computer Science Student")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Humboldt University Berlin")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Monthly Earnings Limit (German Law)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Monthly Earnings Limit")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Current Earnings")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("€\(String(format: "%.0f", currentEarnings))")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("German Law Limit")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("€\(String(format: "%.0f", monthlyLimit))")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                
                                ProgressView(value: currentEarnings, total: monthlyLimit)
                                    .progressViewStyle(LinearProgressViewStyle(tint: currentEarnings >= monthlyLimit * 0.8 ? .red : .blue))
                                
                                HStack {
                                    Text("Remaining: €\(String(format: "%.0f", monthlyLimit - currentEarnings))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(String(format: "%.0f", (currentEarnings / monthlyLimit) * 100))% used")
                                        .font(.caption)
                                        .foregroundColor(currentEarnings >= monthlyLimit * 0.8 ? .red : .secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Payment Information
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
                                    .multilineTextAlignment(.trailing)
                            }
                            
                            Button(action: {
                                showingPaymentDetails = true
                            }) {
                                HStack {
                                    Image(systemName: "eurosign.circle.fill")
                                        .foregroundColor(.green)
                                    
                                    Text("Ready for Payments")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.green)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Personal Information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Personal Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Current Address")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(address)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.trailing)
                            }
                            
                            HStack {
                                Text("University")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(university)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.trailing)
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
                .padding(.bottom, 80)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingPaymentDetails) {
            PaymentDetailsView(iban: iban, currentEarnings: currentEarnings, monthlyLimit: monthlyLimit)
        }
    }
}

#Preview {
    StudentProfileView()
}
