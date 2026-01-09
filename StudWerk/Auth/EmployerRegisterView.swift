//
//  EmployerRegisterView.swift
//  test
//
//  Created by Emir Yalçınkaya on 6.01.2026.
//

import SwiftUI

struct EmployerRegisterView: View {
    @EnvironmentObject var app: AppState

    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var companyAddress = ""
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
                labeledTextField("Name", "Enter name", text: $name, keyboard: .default)
                    .textInputAutocapitalization(.words)
                    .textContentType(.organizationName)

                labeledTextField("Email", "Enter email", text: $email, keyboard: .emailAddress)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)

                labeledTextField("Phone Number", "Enter phone number", text: $phone, keyboard: .phonePad)
                    .textContentType(.telephoneNumber)

                labeledTextField("Address", "Enter address", text: $companyAddress, keyboard: .default)
                    .textInputAutocapitalization(.words)
                    .textContentType(.fullStreetAddress)

                labeledSecureField("Password", "Create a password", text: $password, contentType: .newPassword)
                labeledSecureField("Confirm Password", "Confirm password", text: $confirmPassword, contentType: .newPassword)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 12, y: 5)
            )

            Button(action: registerEmployer) {
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

    private func labeledSecureField(_ title: String, _ placeholder: String, text: Binding<String>, contentType: UITextContentType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            SecureField(placeholder, text: text)
                .textContentType(contentType)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func registerEmployer() {
        // Validate all fields
        let nameValidation = InputValidator.validateName(name)
        if !nameValidation.isValid {
            alertMessage = nameValidation.errorMessage ?? "Invalid name"
            showingAlert = true
            return
        }
        
        let emailValidation = InputValidator.validateEmail(email)
        if !emailValidation.isValid {
            alertMessage = emailValidation.errorMessage ?? "Invalid email"
            showingAlert = true
            return
        }
        
        let phoneValidation = InputValidator.validatePhone(phone)
        if !phoneValidation.isValid {
            alertMessage = phoneValidation.errorMessage ?? "Invalid phone number"
            showingAlert = true
            return
        }
        
        let addressValidation = InputValidator.validateAddress(companyAddress)
        if !addressValidation.isValid {
            alertMessage = addressValidation.errorMessage ?? "Invalid address"
            showingAlert = true
            return
        }
        
        let passwordValidation = InputValidator.validatePassword(password)
        if !passwordValidation.isValid {
            alertMessage = passwordValidation.errorMessage ?? "Invalid password"
            showingAlert = true
            return
        }
        
        let passwordConfirmationValidation = InputValidator.validatePasswordConfirmation(password, confirmPassword)
        if !passwordConfirmationValidation.isValid {
            alertMessage = passwordConfirmationValidation.errorMessage ?? "Passwords do not match"
            showingAlert = true
            return
        }

        isLoading = true

        Task {
            do {
                let res = try await AuthManager.shared.registerEmployer(
                    name: name,
                    email: email,
                    phone: phone,
                    companyAddress: companyAddress,
                    password: password
                )

                await MainActor.run {
                    isLoading = false
                    app.loginSuccess(uid: res.uid, email: res.email, type: res.type)
                }

            } catch {
                let ns = error as NSError
                
                await MainActor.run {
                    isLoading = false
                    alertMessage = """
                    \(ns.domain) (code: \(ns.code))
                    \(ns.localizedDescription)
                    \(ns.userInfo)
                    """
                    showingAlert = true
                }
            }
        }
    }
}

#Preview("EmployerRegisterView") {
    NavigationStack {
        EmployerRegisterView()
            .environmentObject(AppState())
    }
}
