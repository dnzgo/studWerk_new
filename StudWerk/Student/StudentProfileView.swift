//
//  StudentProfileView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI
import FirebaseFirestore
import Combine

struct StudentProfileView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var languageManager = LanguageManager.shared
    @State private var showingSettings = false
    @State private var currentEarnings = 0.0
    @State private var monthlyLimit = 1100.0
    @State private var iban = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var showingPaymentDetails = false
    @State private var studentName = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                if isLoading {
                    ProgressView(languageManager.localizedString(for: "profile.loading"))
                        .padding(.top, 100)
                } else {
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
                            Text(studentName.isEmpty ? languageManager.localizedString(for: "profile.student") : studentName)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(languageManager.localizedString(for: "profile.student"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Monthly Earnings Limit (German Law)
                    VStack(alignment: .leading, spacing: 16) {
                        Text(languageManager.localizedString(for: "profile.monthlyEarningsLimit"))
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text(languageManager.localizedString(for: "profile.currentEarnings"))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("€\(String(format: "%.0f", currentEarnings))")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(languageManager.localizedString(for: "profile.germanLawLimit"))
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
                                    Text("\(languageManager.localizedString(for: "profile.remaining")): €\(String(format: "%.0f", monthlyLimit - currentEarnings))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(String(format: "%.0f", (currentEarnings / monthlyLimit) * 100))\(languageManager.localizedString(for: "profile.percentUsed"))")
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
                        Text(languageManager.localizedString(for: "profile.paymentInformation"))
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text(languageManager.localizedString(for: "profile.iban"))
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
                                    
                                    Text(languageManager.localizedString(for: "profile.readyForPayments"))
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
                        Text(languageManager.localizedString(for: "profile.personalInformation"))
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text(languageManager.localizedString(for: "profile.phoneNumber"))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(phone)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.trailing)
                            }
                            
                            HStack {
                                Text(languageManager.localizedString(for: "profile.address"))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(address)
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
                            
                            Text(languageManager.localizedString(for: "profile.settings"))
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
            }
            .navigationTitle(languageManager.localizedString(for: "profile.title"))
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingPaymentDetails) {
            PaymentDetailsView(iban: iban, currentEarnings: currentEarnings, monthlyLimit: monthlyLimit)
        }
        .onAppear {
            Task {
                await loadProfileData()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("StudentProfileUpdated"))) { _ in
            Task {
                await loadProfileData()
            }
        }
        .alert(languageManager.localizedString(for: "profile.error"), isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func loadProfileData() async {
        guard let studentID = appState.uid else {
            await MainActor.run {
                errorMessage = languageManager.localizedString(for: "profile.errorMessage")
            }
            return
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let db = Firestore.firestore()
            
            // Load student data from students collection
            let studentDoc = try await db.collection("students").document(studentID).getDocument()
            
            if let data = studentDoc.data() {
                await MainActor.run {
                    studentName = data["name"] as? String ?? ""
                    iban = data["iban"] as? String ?? ""
                    address = data["address"] as? String ?? ""
                    phone = data["phone"] as? String ?? ""
                }
            }
            
            // Calculate monthly earnings from completed applications in current month only
            let applications = try await ApplicationManager.shared.fetchApplicationsByStudent(studentID: studentID, status: .completed)
            
            // Get current month's start and end dates
            let calendar = Calendar.current
            let now = Date()
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let nextMonth = calendar.date(byAdding: DateComponents(month: 1), to: startOfMonth)!
            let endOfMonth = calendar.date(byAdding: DateComponents(second: -1), to: nextMonth)!
            
            // Filter applications from current month and calculate earnings
            let monthlyEarnings = applications
                .filter { app in
                    // Check if jobDate is within current month (1st to last day)
                    let jobDate = app.jobDate
                    return jobDate >= startOfMonth && jobDate <= endOfMonth
                }
                .reduce(0.0) { total, app in
                    // Extract payment amount from string like "€150" or "150"
                    let paymentString = app.jobPayment
                    let numbers = paymentString.components(separatedBy: CharacterSet.decimalDigits.inverted)
                        .compactMap { Double($0) }
                    let amount = numbers.first ?? 0.0
                    return total + amount
                }
            
            await MainActor.run {
                currentEarnings = monthlyEarnings
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                let errorFormat = languageManager.localizedString(for: "profile.loadError")
                errorMessage = String(format: errorFormat, error.localizedDescription)
                print("Error loading profile: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    StudentProfileView()
}
