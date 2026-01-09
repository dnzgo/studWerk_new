//
//  StudentSearchView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI

struct StudentSearchView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = StudentSearchViewModel()
    @State private var showingFilters = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Header
                VStack(spacing: 16) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search jobs, companies, locations...", text: $viewModel.searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !viewModel.searchText.isEmpty {
                            Button(action: {
                                viewModel.clearSearch()
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
                            ForEach(viewModel.sortOptions, id: \.self) { option in
                                Button(option.rawValue) {
                                    viewModel.sortBy = option
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text("Sort: \(viewModel.sortBy.rawValue)")
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
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 40)
                    } else if viewModel.filteredJobs.isEmpty {
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
                            ForEach(viewModel.filteredJobs, id: \.id) { job in
                                JobCard(job: job)
                                    .environmentObject(appState)
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
                selectedCategory: $viewModel.selectedCategory,
                selectedDate: $viewModel.selectedDate,
                categories: viewModel.categories
            )
        }
        .task {
            await viewModel.loadJobs()
        }
        .refreshable {
            await viewModel.loadJobs()
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

#Preview {
    StudentSearchView()
}
