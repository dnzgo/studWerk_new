//
//  StatCard.swift
//  
//
//  Created by Deniz Gözcü on 05.01.26.
//
import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack (alignment :  .leading, spacing : 12) {
            HStack {
                Image (systemName : icon)
                    .font(.title2)
                    .foregroundColor(color)
                    
            }
            
            VStack(alignment : .leading, spacing : 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
