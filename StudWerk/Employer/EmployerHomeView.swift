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
                            }
                            
                            Spacer()
                            
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    
                    // statistic cards
                    VStack(spacing : 16) {
                        HStack(spacing : 16) {
                            StatCard(
                                title: "Active Jobs",
                                value: "12",
                                color: .blue,
                                icon: "briefcase.fill")
                            
                            StatCard(
                                title: "Applications",
                                value: "45",
                                color: .green,
                                icon: "doc.text.fill")
                        }
                        HStack(spacing : 16) {
                            StatCard(
                                title: "Hired Students",
                                value: "23",
                                color: .orange,
                                icon: "person.2.fill")
                            
                            StatCard(
                                title: "Total Spend",
                                value: "€2.4K",
                                color: .purple,
                                icon: "eurosign.circle.fill")
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
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(recentApplications, id: \.id) { application in ApplicationSummaryCard(application: application)
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


let recentApplications = [
    ApplicationSummary(studentName: "Max Mustermann", position: "Software Developer Intern", timeAgo: "2h ago"),
    ApplicationSummary(studentName: "Anna Schmidt", position: "Marketing Assistant", timeAgo: "4h ago"),
    ApplicationSummary(studentName: "Tom Weber", position: "Sales Assistant", timeAgo: "6h ago")
]


#Preview {
    EmployerHomeView()
}
