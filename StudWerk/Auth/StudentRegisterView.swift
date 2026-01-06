//
//  StudentRegisterView.swift
//  test
//
//  Created by Emir Yalçınkaya on 6.01.2026.
//

import SwiftUI

struct StudentRegisterView: View {
    @EnvironmentObject var app: AppState

    @State private var fullName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var uniEmail = ""
    @State private var iban = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 18) {

            Text("Create Account")
                .font(.title2).bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)

            VStack(spacing: 14) {
                labeledTextField("Full Name", "Enter your full name", text: $fullName, keyboard: .default)
                    .textInputAutocapitalization(.words)
                    .textContentType(.name)

                labeledTextField("Email", "Enter your email", text: $email, keyboard: .emailAddress)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)

                labeledTextField("Phone Number", "Enter your phone number", text: $phone, keyboard: .phonePad)
                    .textContentType(.telephoneNumber)

                labeledTextField("University Email", "your.name@university.de", text: $uniEmail, keyboard: .emailAddress)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)

                labeledTextField("Bank Account (IBAN)", "DE89 3704 0044 0532 0130 00", text: $iban, keyboard: .default)
                    .textInputAutocapitalization(.characters)

                labeledSecureField("Password", "Create a password", text: $password, contentType: .newPassword)
                labeledSecureField("Confirm Password", "Confirm password", text: $confirmPassword, contentType: .newPassword)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 12, y: 5)
            )

            Button(action: registerStudent) {
                HStack {
                    if isLoading {
                        ProgressView().progressViewStyle(.circular)
                    } else {
                        Text("Create Account")
                            .font(.headline).fontWeight(.semibold)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isLoading ? Color.gray : Color.blue)
                .cornerRadius(12)
            }
            .disabled(isLoading)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 30)
        .navigationTitle("Student Register")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Register Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: { Text(alertMessage) }
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

    private func labeledSecureField(_ title: String, _ placeholder: String, text: Binding<String>, contentType: UITextContentType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            SecureField(placeholder, text: text)
                .textContentType(contentType)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func registerStudent() {
        guard !fullName.isEmpty, !email.isEmpty, !phone.isEmpty,
              !uniEmail.isEmpty, !iban.isEmpty,
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

        isLoading = true

        Task {
            do {
                let res = try await AuthManager.shared.registerStudent(
                    fullName: fullName,
                    email: email,
                    phone: phone,
                    uniEmail: uniEmail,
                    iban: iban,
                    password: password
                )

                await MainActor.run {
                    isLoading = false
                    app.loginSuccess(uid: res.uid, email: res.email, type: res.type)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }
}

#Preview("StudentRegisterView") {
    NavigationStack {
        StudentRegisterView().environmentObject(AppState())
    }
}

