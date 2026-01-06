//
//  StudWerkApp.swift
//  StudWerk
//
//  Created by Deniz Gözcü on 05.01.26.
//

import SwiftUI
import FirebaseCore

class AppDelegate : NSObject , UIApplicationDelegate {    
  func application ( _application : UIApplication , 
                   didFinishLaunchingWithOptions launchOptions : [ UIApplication . LaunchOptionsKey : Any ]? = nil ) -> Bool {        
      FirebaseApp.configure()

    return true 
  }
}

@main
struct StudWerkApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
