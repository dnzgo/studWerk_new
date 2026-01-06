//
//  LoginView.swift
//  test
//
//  Created by Emir Yalçınkaya on 6.01.2026.
//

import SwiftUI

struct LoginView: View {
    @Binding var isAuthenticated: Bool
    @Binding var path: [Route]

    @State private var email = ""
    @State private var password = ""

    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            Spacer(minLength: 0)

            VStack(spacing: 22) {

                // Header
                VStack(spacing: 10) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.blue)

                    Text("StudWerk")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Login to continue")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Form Card (plain)
                VStack(spacing: 14) {
                    labeledTextField(
                        title: "Email",
                        placeholder: "Enter your email",
                        text: $email,
                        keyboard: .emailAddress
                    )
                    .textInputAutocapitalization(.never)

                    labeledSecureField(
                        title: "Password",
                        placeholder: "Enter your password",
                        text: $password
                    )
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 12, y: 5)
                )

                // Sign in
                Button(action: handleLogin) {
                    Text("Sign In")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.top, 6)

                // Register
                Button {
                    path.append(.userType)
                } label: {
                    Text("Don't have an account? Register")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .alert("Login Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }

    private func labeledTextField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
        }
    }

    private func labeledSecureField(
        title: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            SecureField(placeholder, text: text)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func handleLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in email and password."
            showingAlert = true
            return
        }

        // Demo success
        isAuthenticated = true
        path = [.home(.student)]
    }
}

#Preview("LoginView") {
    NavigationStack {
        LoginView(isAuthenticated: .constant(false), path: .constant([]))
    }
}
