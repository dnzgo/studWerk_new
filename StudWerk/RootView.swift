//
//  RootView.swift
//  studwerktest
//
//  Created by Emir Yalçınkaya on 6.01.2026.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        NavigationStack {
            switch app.screen {
            case .login:
                LoginView()
            case .userType:
                UserTypeSelectionView()
            case .studentRegister:
                StudentRegisterView()
            case .employerRegister:
                EmployerRegisterView()
            case .main(let type):
                MainTabView(userType: type)
            }
        }
    }
}
