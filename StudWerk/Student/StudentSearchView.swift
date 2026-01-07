//
//  StudentSearchView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI

struct StudentSearchView: View {
    @State private var searchText = ""
    @State private var selectedCategory = "General"
    @State private var selectedDate = Date()
    @State private var showingFilters = false
    @State private var sortBy = "Relevance"
    @State private var selectedJob: Job? = nil
    @State private var jobs: [Job] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    let categories = ["General", "Technology", "Retail", "Food Service", "Marketing", "Administration", "Customer Service", "Other"]
    let sortOptions = ["Relevance", "Pay (High to Low)", "Pay (Low to High)", "Date"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Header
                VStack(spacing: 16) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search jobs, companies, locations...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Filter and Sort Row
                    HStack {
                        Button(action: {
                            showingFilters = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "slider.horizontal.3")
                                Text("Filters")
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        Spacer()
                        
                        Menu {
                            ForEach(sortOptions, id: \.self) { option in
                                Button(option) {
                                    sortBy = option
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text("Sort: \(sortBy)")
                                Image(systemName: "chevron.down")
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .background(Color(.systemBackground))
                
                // Results
                ScrollView {
                    if isLoading {
                        ProgressView()
                            .padding(.top, 40)
                    } else if filteredJobs.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            Text("No jobs found")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Try adjusting your search or filters")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 40)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredJobs, id: \.id) { job in
                                SearchJobCard(job: job)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
            }
            .navigationTitle("Search Jobs")
        }
        .sheet(isPresented: $showingFilters) {
            SearchFiltersView(
                selectedCategory: $selectedCategory,
                selectedDate: $selectedDate,
                categories: categories
            )
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
    
    private func loadJobs() async {
        print("🔍 StudentSearchView: Loading jobs")
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let fetchedJobs = try await JobManager.shared.fetchJobs(status: "open")
            print("✅ StudentSearchView: Fetched \(fetchedJobs.count) jobs")
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
    
    private var filteredJobs: [Job] {
        var filtered = jobs
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { job in
                job.company.localizedCaseInsensitiveContains(searchText) ||
                job.position.localizedCaseInsensitiveContains(searchText) ||
                job.location.localizedCaseInsensitiveContains(searchText) ||
                job.jobDescription.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by category
        if selectedCategory != "All" {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // Removed pay range filter - students can see all jobs with fixed payments
        
        // Sort jobs
        switch sortBy {
        case "Pay (High to Low)":
            filtered.sort { extractPayFromString($0.pay) > extractPayFromString($1.pay) }
        case "Pay (Low to High)":
            filtered.sort { extractPayFromString($0.pay) < extractPayFromString($1.pay) }
        case "Date":
            filtered.sort { $0.date > $1.date }
        default:
            break // Relevance - keep original order
        }
        
        return filtered
    }
    
    private func extractPayFromString(_ payString: String) -> Double {
        let numbers = payString.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Double($0) }
        return numbers.first ?? 0
    }
}

#Preview {
    StudentSearchView()
}
