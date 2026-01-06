//
//  StudentHomeView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI

struct StudentHomeView: View {
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Find your next job opportunity")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    
                    // Quick Stats
                    HStack(spacing: 16) {
                        QuickStatCard(
                            title: "Available Jobs",
                            value: "24",
                            icon: "briefcase.fill",
                            color: .blue
                        )
                        
                        QuickStatCard(
                            title: "Applications",
                            value: "3",
                            icon: "doc.text.fill",
                            color: .green
                        )
                        
                        QuickStatCard(
                            title: "Earnings",
                            value: "€450",
                            icon: "eurosign.circle.fill",
                            color: .orange
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Featured Jobs Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Featured Jobs")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Button("See All") {
                                // Handle see all
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                FeaturedJobCard(
                                    company: "Tech Startup GmbH",
                                    position: "Software Developer Intern",
                                    pay: "€18/hour",
                                    location: "Berlin",
                                    duration: "3 months",
                                    isRemote: false
                                )
                                
                                FeaturedJobCard(
                                    company: "Café Central",
                                    position: "Barista",
                                    pay: "€12/hour",
                                    location: "Mitte, Berlin",
                                    duration: "Flexible",
                                    isRemote: false
                                )
                                
                                FeaturedJobCard(
                                    company: "Digital Agency",
                                    position: "Content Writer",
                                    pay: "€15/hour",
                                    location: "Remote",
                                    duration: "6 months",
                                    isRemote: true
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Nearby Jobs Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Nearby Jobs")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Button("View All") {
                                // Handle navigate to nearby jobs
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 20)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(getSampleJobs(), id: \.id) { job in
                                JobCard(job: job)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("StudWerk")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
#Preview {
    StudentHomeView()
}
