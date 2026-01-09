//
//  StudentSearchViewModel.swift
//  StudWerk
//
//  Created on 07.01.26.
//

import Foundation
import Combine

enum SortOption: String, CaseIterable {
    case relevance = "Relevance"
    case payHighToLow = "Pay (High to Low)"
    case payLowToHigh = "Pay (Low to High)"
    case date = "Date"
}

@MainActor
final class StudentSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory = "General"
    @Published var selectedDate = Date()
    @Published var sortBy: SortOption = .relevance
    @Published var jobs: [Job] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    let categories = ["General", "Technology", "Retail", "Food Service", "Marketing", "Administration", "Customer Service", "Other"]
    
    // MARK: - Computed Properties
    
    var filteredJobs: [Job] {
        var filtered = jobs
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { job in
                job.jobTitle.localizedCaseInsensitiveContains(searchText) ||
                job.location.localizedCaseInsensitiveContains(searchText) ||
                job.jobDescription.localizedCaseInsensitiveContains(searchText) ||
                job.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by category
        if selectedCategory != "General" && selectedCategory != "All" {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // Filter by date (jobs on or after selected date) - only if date is set to a future date
        // If date is today or past, don't filter by date
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDateStart = calendar.startOfDay(for: selectedDate)
        
        if selectedDateStart > today {
            filtered = filtered.filter { job in
                let jobDateStart = calendar.startOfDay(for: job.date)
                return calendar.isDate(jobDateStart, inSameDayAs: selectedDateStart) ||
                       jobDateStart > selectedDateStart
            }
        }
        
        // Sort jobs
        switch sortBy {
        case .payHighToLow:
            filtered.sort { extractPayFromString($0.payment) > extractPayFromString($1.payment) }
        case .payLowToHigh:
            filtered.sort { extractPayFromString($0.payment) < extractPayFromString($1.payment) }
        case .date:
            filtered.sort { $0.date > $1.date }
        case .relevance:
            // Relevance: prioritize jobs matching search text in title, then location, then description
            if !searchText.isEmpty {
                filtered.sort { job1, job2 in
                    let score1 = relevanceScore(job1, searchText: searchText)
                    let score2 = relevanceScore(job2, searchText: searchText)
                    return score1 > score2
                }
            }
        }
        
        return filtered
    }
    
    var sortOptions: [SortOption] {
        SortOption.allCases
    }
    
    // MARK: - Methods
    
    func loadJobs() async {
        print("StudentSearchViewModel: Loading jobs")
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedJobs = try await JobManager.shared.fetchJobs(status: .open)
            print("StudentSearchViewModel: Fetched \(fetchedJobs.count) jobs")
            self.jobs = fetchedJobs
            isLoading = false
            errorMessage = nil
        } catch {
            isLoading = false
            let errorDesc = error.localizedDescription
            errorMessage = "Failed to load jobs: \(errorDesc)"
            print("Error loading jobs: \(errorDesc)")
        }
    }
    
    func clearSearch() {
        searchText = ""
    }
    
    // MARK: - Private Helpers
    
    private func extractPayFromString(_ payString: String) -> Double {
        let numbers = payString.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Double($0) }
        return numbers.first ?? 0
    }
    
    private func relevanceScore(_ job: Job, searchText: String) -> Int {
        var score = 0
        let lowerSearchText = searchText.lowercased()
        
        // Title match gets highest score
        if job.jobTitle.lowercased().contains(lowerSearchText) {
            score += 10
        }
        
        // Location match
        if job.location.lowercased().contains(lowerSearchText) {
            score += 5
        }
        
        // Category match
        if job.category.lowercased().contains(lowerSearchText) {
            score += 3
        }
        
        // Description match
        if job.jobDescription.lowercased().contains(lowerSearchText) {
            score += 1
        }
        
        return score
    }
}
