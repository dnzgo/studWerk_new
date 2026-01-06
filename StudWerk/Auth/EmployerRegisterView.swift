//
//  EmployerRegisterView.swift
//  test
//
//  Created by Emir Yalçınkaya on 6.01.2026.
//

import SwiftUI

struct EmployerRegisterView: View {
    @Binding var isAuthenticated: Bool
    @Binding var path: [Route]

    @State private var companyName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var companyAddress = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {

                Text("Create Account")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)

                VStack(spacing: 14) {
                    labeledTextField("Company Name", "Enter company name", text: $companyName, keyboard: .default)
                        .textInputAutocapitalization(.words)

                    labeledTextField("Email", "Enter email", text: $email, keyboard: .emailAddress)
                        .textInputAutocapitalization(.never)

                    labeledTextField("Phone Number", "Enter phone number", text: $phone, keyboard: .phonePad)

                    labeledTextField("Company Address", "Enter company address", text: $companyAddress, keyboard: .default)
                        .textInputAutocapitalization(.words)

                    labeledSecureField("Password", "Create a password", text: $password)
                    labeledSecureField("Confirm Password", "Confirm password", text: $confirmPassword)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 12, y: 5)
                )

                Button(action: registerEmployer) {
                    Text("Create Account")
                        .font(.headline).fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                }

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
        .navigationTitle("Employer Register")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Register Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }

    private func labeledTextField(_ title: String, _ placeholder: String, text: Binding<String>, keyboard: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
        }
    }

    private func labeledSecureField(_ title: String, _ placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            SecureField(placeholder, text: text)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func registerEmployer() {
        guard !companyName.isEmpty, !email.isEmpty, !phone.isEmpty,
              !companyAddress.isEmpty,
              !password.isEmpty, !confirmPassword.isEmpty else {
            alertMessage = "Please fill in all required fields."
            showingAlert = true
            return
        }

        guard password == confirmPassword else {
            alertMessage = "Passwords do not match."
            showingAlert = true
            return
        }

        isAuthenticated = true
        path = [.home(.employer)]
    }
}

#Preview("EmployerRegisterView") {
    NavigationStack {
        EmployerRegisterView(isAuthenticated: .constant(false), path: .constant([]))
    }
}
