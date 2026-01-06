//
//  ApplicationSummaryCard.swift
//
//
//  Created by Deniz Gözcü on 05.01.26.
//

import SwiftUI

struct ApplicationSummaryCard: View {
    let application: ApplicationSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(application.studentName)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(application.position)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(application.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {

                Button("Review") {
                    // Handle review
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .frame(width: 200)
    }
}
struct ApplicationSummary : Identifiable {
    var id: UUID = UUID()
    var studentName: String
    var position: String
    var timeAgo: String
}

