//
//  ApplicationStatus.swift
//  StudWerk
//
//  Created on 07.01.26.
//

import SwiftUI
import Foundation

enum ApplicationStatus: String, CaseIterable, Codable {
    case pending = "Pending"
    case accepted = "Accepted"
    case rejected = "Rejected"
    case completed = "Completed"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .accepted: return "Accepted"
        case .rejected: return "Rejected"
        case .completed: return "Completed"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .accepted: return .green
        case .rejected: return .red
        case .completed: return .blue
        }
    }
}
