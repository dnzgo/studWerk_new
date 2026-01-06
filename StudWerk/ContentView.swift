//
//  ContentView.swift
//  StudWerk
//
//  Created by Deniz Gözcü on 05.01.26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthService()
    @State private var path: [Route] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if authService.isAuthenticated, let user = authService.currentUser {
                    // User is authenticated - show main app
                    MainTabView(userType: user.userType)
                } else {
                    // User is not authenticated - show login
                    LoginView(
                        isAuthenticated: $authService.isAuthenticated,
                        path: $path
                    )
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .userType:
                    UserTypeSelectionView(path: $path)
                    
                case .register(let userType):
                    if userType == .student {
                        StudentRegisterView(
                            isAuthenticated: $authService.isAuthenticated,
                            path: $path
                        )
                    } else {
                        EmployerRegisterView(
                            isAuthenticated: $authService.isAuthenticated,
                            path: $path
                        )
                    }
                    
                case .home(let userType):
                    MainTabView(userType: userType)
                }
            }
        }
        .environmentObject(authService)
    }
}

#Preview {
    ContentView()
}
