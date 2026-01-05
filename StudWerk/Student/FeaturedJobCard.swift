//
//  FeaturedJobCard.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI

struct FeaturedJobCard: View {
    let company: String
    let position: String
    let pay: String
    let location: String
    let duration: String
    let isRemote: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(company)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Text(position)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                if isRemote {
                    Image(systemName: "house.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            
            HStack {
                Image(systemName: "eurosign.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                
                Text(pay)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Text(location)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(duration)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button("Apply Now") {
                // Handle apply
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(Color.blue)
            .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .frame(width: 280)
    }
}

