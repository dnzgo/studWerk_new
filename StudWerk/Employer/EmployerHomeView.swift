//
//  EmployerHomeView.swift
//  StudWerk
//
//  Created by Deniz Gözcü on 5.01.2026.
//

import SwiftUI

struct EmployerHomeView: View {
    
    var body : some View {
        NavigationView {
            ScrollView {
                VStack (spacing : 24) {
                    // header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing : 4) {
                                Text("Dashboard")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Text("Dashboard")
                                    .font(.subheadline)
                                    .fontWeight(.secondary)
                            }
                            
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    
                    // statistic cards
                    VStack(spacing : 16) {
                        HStack(spacing : 16) {
                            StatCard(title: "Active Jobs", value: "12", icon: "briefcase.fill", color: .blue)
                            StatCard(title: "Applications", value: "45", icon: "doc.text.fill", color: .green)
                        }
                        HStack(spacing : 16) {
                            StatCard(title: "Hired Students", value: "23", icon: "person.2.fill", color: .orange)
                            StatCard(title: "Total Spend", value: "€2.4K", icon: "eurosign.circle.fill", color: .purple)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // recent applications
                    VStack(alignment : .leading, spacing : 16) {
                        HStack {
                            Text("Recent Applications")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Button("View All") {
                                // handle navigation to applications
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showIndicators : false) {
                            HStack(spacing : 16) {
                                ForEach(recentApplications, id : \.id) {
                                    application in
                                    ApplicationSummaryCard(application: application))
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                    }
                }
            }
        }
    }
}

#Preview {
    EmployerHomeView()
}
