//
//  Route.swift
//  test
//
//  Created by Emir Yalçınkaya on 6.01.2026.
//

import Foundation

enum Route: Hashable {
    case userType
    case register(UserType)
    case home(UserType)
}
