//
//  MainTabView.swift
//  StudWerk
//
//  Created by Emir Yalçınkaya on 5.01.2026.
//

import SwiftUI
import Combine

struct MainTabView: View {
    let userType: UserType
    @State var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            
            if(userType == .student){
                
                StudentHomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                
                StudentSearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    .tag(1)
                
                StudentApplicationsView()
                    .tabItem {
                        Image(systemName: "doc.text.fill")
                        Text("Applications")
                    }
                    .tag(2)
                
                StudentProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                    .tag(3)
                
            } else {
                
                EmployerHomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                
                EmployerCreateJobView()
                    .tabItem {
                        Image(systemName: "plus.circle.fill")
                        Text("Post Job")
                    }
                    .tag(1)
                
                EmployerJobsView()
                    .tabItem {
                        Image(systemName: "briefcase.fill")
                        Text("My Jobs")
                    }
                    .tag(2)
                
                EmployerProfileView()
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                        Text("Profile")
                    }
                    .tag(3)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToApplications"))) { _ in
            // Switch to My Jobs tab (index 2)
            selectedTab = 2
        }
    }
}
