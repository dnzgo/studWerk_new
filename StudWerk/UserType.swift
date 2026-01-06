//
//  UserType.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import Foundation

enum UserType: String, Codable, CaseIterable, Identifiable {
    case student
    case employer
    
    var id: String { rawValue }

       var title: String {
           switch self {
           case .student: return "Student"
           case .employer: return "Employer"
        }
    }
}
