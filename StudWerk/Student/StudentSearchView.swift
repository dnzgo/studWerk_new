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
    @State private var isRemote = false
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
                isRemote: $isRemote,
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

struct SearchJobCard: View {
    let job: Job
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.company)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Text(job.position)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    
                    Text(job.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(6)
                }
            }
            
            HStack {
                Image(systemName: "eurosign.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                
                Text(job.pay)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "clock.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                
                Text(job.dateString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Text(job.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(job.distance)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !job.description.isEmpty {
                Text(job.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Button("View Details") {
                    // Handle view details
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                
                Spacer()
                
                Button("Apply") {
                    // Handle apply
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(6)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SearchFiltersView: View {
    @Binding var selectedCategory: String
    @Binding var selectedDate: Date
    @Binding var isRemote: Bool
    let categories: [String]
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Category Filter
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(categories, id: \.self) { category in
                                FilterButton(
                                    title: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    
                    // Date Filter
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Available Date")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    
                    // Remote Work Filter
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Work Type")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Text("Remote Work Only")
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Toggle("", isOn: $isRemote)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Reset") {
                    resetFilters()
                },
                trailing: Button("Apply") {
                    dismiss()
                }
            )
        }
    }
    
    private func resetFilters() {
        selectedCategory = "All"
        selectedDate = Date()
        isRemote = false
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.blue : Color.blue.opacity(0.1))
                )
        }
    }
}

#Preview {
    StudentSearchView()
}
