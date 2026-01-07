//
//  StudentContactView.swift
//  StudWerk
//
//  Created on 07.01.26.
//

import SwiftUI

struct StudentContactView: View {
    let studentName: String
    let email: String
    let phone: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Contact Student")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(studentName.isEmpty ? "Student" : studentName)
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Divider()
                    .padding(.horizontal, 20)
                
                // Contact Information
                VStack(alignment: .leading, spacing: 20) {
                    if !email.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                                
                                Text(email)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button(action: {
                                    if let url = URL(string: "mailto:\(email)") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    
                    if !phone.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Phone")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.green)
                                    .font(.title3)
                                
                                Text(phone)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button(action: {
                                    if let url = URL(string: "tel:\(phone)") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    
                    if email.isEmpty && phone.isEmpty {
                        Text("Contact information not available")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .navigationTitle("Contact")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        StudentContactView(
            studentName: "John Doe",
            email: "john.doe@example.com",
            phone: "+49 30 12345678"
        )
    }
}

