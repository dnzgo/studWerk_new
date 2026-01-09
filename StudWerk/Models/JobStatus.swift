//
//  JobStatus.swift
//  StudWerk
//
//  Created on 07.01.26.
//

import Foundation

enum JobStatus: String, Codable, CaseIterable {
    case open = "open"
    case closed = "closed"
    case completed = "completed"
    
    var displayName: String {
        switch self {
        case .open: return "Open"
        case .closed: return "Closed"
        case .completed: return "Completed"
        }
    }
}
