//
//  LanguageManager.swift
//  StudWerk
//
//  Created on 08.01.26.
//

import Foundation
import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case german = "de"
    case turkish = "tr"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .german: return "Deutsch"
        case .turkish: return "Türkçe"
        }
    }
    
    var localeCode: String {
        return rawValue
    }
}

final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "studentProfileLanguage")
        }
    }
    
    private init() {
        // Load from UserDefaults, default to English
        if let savedLanguage = UserDefaults.standard.string(forKey: "studentProfileLanguage"),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            self.currentLanguage = .english
        }
    }
    
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
    }
    
    private func bundleForLanguage(_ language: AppLanguage) -> Bundle? {
        guard let path = Bundle.main.path(forResource: language.localeCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.main // Fallback to main bundle
        }
        return bundle
    }
    
    func localizedString(for key: String) -> String {
        guard let bundle = bundleForLanguage(currentLanguage) else {
            // Fallback: try to load from main bundle with table name
            return NSLocalizedString(key, tableName: "StudentProfileLocalizable", bundle: Bundle.main, value: key, comment: "")
        }
        // Load from the specific language bundle with table name
        return NSLocalizedString(key, tableName: "StudentProfileLocalizable", bundle: bundle, value: key, comment: "")
    }
}
