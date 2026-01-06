//
//  RegisterView.swift
//  test
//
//  Created by Emir Yalçınkaya on 6.01.2026.
//

import SwiftUI

struct StudentRegisterView: View {
    @EnvironmentObject var authService: AuthService
    @Binding var isAuthenticated: Bool
    @Binding var path: [Route]

    @State private var fullName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var uniEmail = ""
    @State private var iban = ""
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
                    labeledTextField("Full Name", "Enter your full name", text: $fullName, keyboard: .default)
                        .textInputAutocapitalization(.words)

                    labeledTextField("Email", "Enter your email", text: $email, keyboard: .emailAddress)
                        .textInputAutocapitalization(.never)

                    labeledTextField("Phone Number", "Enter your phone number", text: $phone, keyboard: .phonePad)

                    labeledTextField("University Email", "your.name@university.de", text: $uniEmail, keyboard: .emailAddress)
                        .textInputAutocapitalization(.never)

                    labeledTextField("Bank Account (IBAN)", "DE89 3704 0044 0532 0130 00", text: $iban, keyboard: .default)
                        .textInputAutocapitalization(.characters)

                    labeledSecureField("Password", "Create a password", text: $password)
                    labeledSecureField("Confirm Password", "Confirm password", text: $confirmPassword)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 12, y: 5)
                )

                Button(action: registerStudent) {
                    HStack {
                        if authService.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Create Account")
                                .font(.headline).fontWeight(.semibold)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(authService.isLoading ? Color.gray : Color.blue)
                    .cornerRadius(12)
                }
                .disabled(authService.isLoading)

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
        .navigationTitle("Student Register")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Register Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onChange(of: authService.isAuthenticated) { oldValue, newValue in
            if newValue, let user = authService.currentUser {
                path = [.home(user.userType)]
            }
        }
        .onChange(of: authService.errorMessage) { oldValue, newValue in
            if let error = newValue {
                alertMessage = error
                showingAlert = true
            }
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

        Task {
            do {
                try await authService.registerStudent(
                    email: email,
                    password: password,
                    fullName: fullName,
                    phone: phone,
                    uniEmail: uniEmail,
                    iban: iban
                )
                // Navigation is handled by onChange modifier
            } catch {
                alertMessage = authService.errorMessage ?? "Registration failed. Please try again."
                showingAlert = true
            }
        }
    }
}

#Preview("StudentRegisterView") {
    NavigationStack {
        StudentRegisterView(
            isAuthenticated: .constant(false),
            path: .constant([])
        )
        .environmentObject(AuthService())
    }
}