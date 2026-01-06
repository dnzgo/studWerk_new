//
//  AppState.swift
//  studwerktest
//
//  Created by Emir Yalçınkaya on 6.01.2026.
//

import SwiftUI
import Combine

final class AppState: ObservableObject {

    enum Screen: Equatable {
        case login
        case userType
        case studentRegister
        case employerRegister
        case main(UserType)
    }

    @Published var screen: Screen = .login

    // Session
    @Published var uid: String? = nil
    @Published var email: String = ""
    @Published var userType: UserType? = nil

    func goToRegisterFlow() {
        screen = .userType
    }

    func chooseUserType(_ type: UserType) {
        switch type {
        case .student:  screen = .studentRegister
        case .employer: screen = .employerRegister
        }
    }

    func loginSuccess(uid: String, email: String, type: UserType) {
        self.uid = uid
        self.email = email
        self.userType = type
        screen = .main(type)
    }

    func logout() {
        uid = nil
        email = ""
        userType = nil
        screen = .login
    }
}
