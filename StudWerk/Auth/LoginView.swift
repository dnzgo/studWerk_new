//
//  LoginView.swift
//  test
//
//  Created by Emir Yalçınkaya on 6.01.2026.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var app: AppState

    @State private var email = ""
    @State private var password = ""

    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            Spacer(minLength: 0)

            VStack(spacing: 22) {

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

                VStack(spacing: 14) {
                    labeledTextField(
                        title: "Email",
                        placeholder: "Enter your email",
                        text: $email,
                        keyboard: .emailAddress
                    )
                    .textInputAutocapitalization(.never)
                    .textContentType(.username)

                    labeledSecureField(
                        title: "Password",
                        placeholder: "Enter your password",
                        text: $password,
                        contentType: .password
                    )
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 12, y: 5)
                )

                Button(action: handleLogin) {
                    HStack {
                        if isLoading {
                            ProgressView().progressViewStyle(.circular)
                        } else {
                            Text("Sign In")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isLoading ? Color.gray : Color.blue)
                    .cornerRadius(12)
                }
                .disabled(isLoading)
                .padding(.top, 6)

                Button {
                    app.goToRegisterFlow()
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
        } message: { Text(alertMessage) }
    }

    private func labeledTextField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
        }
    }

    private func labeledSecureField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        contentType: UITextContentType
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            SecureField(placeholder, text: text)
                .textContentType(contentType)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func handleLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in email and password."
            showingAlert = true
            return
        }

        isLoading = true

        Task {
            do {
                let res = try await AuthManager.shared.login(email: email, password: password)
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

#Preview("LoginView") {
    NavigationStack {
        LoginView().environmentObject(AppState())
    }
}

