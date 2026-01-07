//
//  StudentHomeView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI

struct StudentHomeView: View {
    @State private var jobs: [Job] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
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
                            value: "\(jobs.count)",
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
                        
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if featuredJobs.isEmpty {
                            Text("No featured jobs available")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(featuredJobs.prefix(3), id: \.id) { job in
                                        FeaturedJobCard(
                                            company: job.company,
                                            position: job.position,
                                            pay: job.pay,
                                            location: job.location,
                                            duration: job.dateString,
                                            isRemote: false
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
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
                        
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if nearbyJobs.isEmpty {
                            Text("No nearby jobs available")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(nearbyJobs.prefix(5), id: \.id) { job in
                                    JobCard(job: job)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("StudWerk")
        }
        .task {
            await loadJobs()
        }
        .refreshable {
            await loadJobs()
        }
        .alert("Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private var featuredJobs: [Job] {
        // Featured jobs are the most recent ones
        return Array(jobs.sorted { $0.createdAt > $1.createdAt }.prefix(3))
    }
    
    private var nearbyJobs: [Job] {
        // For now, return all jobs. Later can filter by location
        return jobs.sorted { $0.createdAt > $1.createdAt }
    }
    
    private func loadJobs() async {
        print("🔍 StudentHomeView: Loading jobs")
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let fetchedJobs = try await JobManager.shared.fetchJobs(status: "open")
            print("✅ StudentHomeView: Fetched \(fetchedJobs.count) jobs")
            await MainActor.run {
                self.jobs = fetchedJobs
                isLoading = false
                errorMessage = nil
            }
        } catch {
            await MainActor.run {
                isLoading = false
                let errorDesc = error.localizedDescription
                errorMessage = "Failed to load jobs: \(errorDesc)"
                print("❌ Error loading jobs: \(errorDesc)")
                print("❌ Full error: \(error)")
            }
        }
    }
}
#Preview {
    StudentHomeView()
}
