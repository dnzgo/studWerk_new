# StudWerk

**StudWerk** is an iOS application built with SwiftUI and Firebase, designed as a job marketplace connecting students with employers for temporary/part-time work opportunities. The app supports two user types: **Students** (job seekers) and **Employers** (job posters).

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Firebase Configuration](#firebase-configuration)
- [Building the Project](#building-the-project)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Key Features](#key-features)
- [Dependencies](#dependencies)

## Prerequisites

Before you begin, ensure you have the following installed:

- **Xcode 15.0 or later** (with Swift 5.9+)
- **macOS 13.0 or later**
- **iOS 16.0+** deployment target
- **Firebase account** (free tier is sufficient)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd studWerk_new
```

### 2. Open the Project

1. Open `StudWerk.xcodeproj` in Xcode
2. Wait for Xcode to resolve Swift Package Manager dependencies (this may take a few minutes on first open)

### 3. Firebase Setup

#### Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard to create your project

#### Step 2: Add iOS App to Firebase

1. In Firebase Console, click "Add app" and select iOS
2. Register your app with:
   - **Bundle ID**: Check your Xcode project's bundle identifier (usually `com.yourcompany.StudWerk`)
   - **App nickname**: StudWerk (optional)
   - **App Store ID**: Leave blank for now
3. Download `GoogleService-Info.plist`

#### Step 3: Configure Firebase in Xcode

1. **Replace the existing `GoogleService-Info.plist`**:
   - Locate `StudWerk/GoogleService-Info.plist` in the project
   - Replace it with the downloaded `GoogleService-Info.plist` from Firebase Console
   - **Important**: Ensure the file is added to the target and included in the project

2. **Verify Firebase Configuration**:
   - The `GoogleService-Info.plist` should be in the `StudWerk/` directory
   - Check that it's included in the Xcode project target

#### Step 4: Enable Firebase Services

In Firebase Console, enable the following services:

1. **Authentication**:
   - Go to Authentication → Sign-in method
   - Enable **Email/Password** provider

2. **Firestore Database**:
   - Go to Firestore Database
   - Click "Create database"
   - Choose **Start in test mode** (for development)
   - Select a location (choose closest to your users)
   - Click "Enable"

#### Step 5: Set Up Firestore Security Rules (Development)

For development, you can use basic rules. **⚠️ Update these for production!**


#### Step 6: Create Firestore Indexes (Optional)

The app will work without these, but you may see warnings.


### 4. Configure Xcode Project

1. **Select Your Development Team**:
   - Open the project in Xcode
   - Select the project in the navigator
   - Go to "Signing & Capabilities" tab
   - Select your Apple Developer Team (or use your personal team for development)

2. **Set Bundle Identifier** (if needed):
   - Ensure the bundle identifier matches what you registered in Firebase
   - Default: `com.yourcompany.StudWerk`

3. **Select Target Device**:
   - Choose a simulator or connected iOS device
   - Minimum iOS version: 16.0

### 5. Build and Run

1. **Resolve Dependencies** (if not already done):
   - Xcode should automatically resolve Swift Package Manager dependencies
   - If not, go to: File → Packages → Resolve Package Versions

2. **Build the Project**:
   - Press `Cmd + B` to build
   - Wait for the build to complete (first build may take longer)

3. **Run the App**:
   - Press `Cmd + R` to run
   - The app should launch on the selected simulator or device

## Building the Project

### First Time Build

1. Open `StudWerk.xcodeproj` in Xcode
2. Wait for Swift Package Manager to resolve dependencies (progress shown in Xcode)
3. Ensure `GoogleService-Info.plist` is properly configured
4. Select a target device (simulator or physical device)
5. Press `Cmd + B` to build
6. Press `Cmd + R` to run

### Troubleshooting Build Issues

**Issue: Package dependencies not resolving**
- Solution: Go to File → Packages → Reset Package Caches, then Resolve Package Versions

**Issue: Firebase not configured error**
- Solution: Ensure `GoogleService-Info.plist` is in the `StudWerk/` directory and added to the target

**Issue: Signing errors**
- Solution: Select your development team in Signing & Capabilities

**Issue: Missing Firestore indexes warnings**
- Solution: The app will work, but create the indexes mentioned above for better performance

## Architecture

### MVVM Pattern

The project follows the **Model-View-ViewModel (MVVM)** architecture pattern:

- **Models**: Data structures (`Job`, `Application`, `User`)
- **Views**: SwiftUI views (presentation layer)
- **ViewModels**: Business logic and state management (`@MainActor` classes)
- **Managers**: Data access layer (singletons for Firebase operations)

### Key Architectural Components

#### State Management
- **AppState**: Centralized app state using `ObservableObject`
- **ViewModels**: Per-view state management with `@Published` properties
- **Environment Objects**: Shared state across views

#### Data Layer
- **Managers**: Singleton classes for Firebase operations
  - `AuthManager`: Authentication
  - `JobManager`: Job CRUD operations
  - `ApplicationManager`: Application management
  - `StudentManager` / `EmployerManager`: Profile management
  - `UserManager`: User settings

#### Navigation
- **RootView**: Handles navigation flow based on authentication state
- **MainTabView**: Tab-based navigation for authenticated users

## Project Structure

```
StudWerk/
├── Auth/                          # Authentication & Registration
│   ├── AuthManager.swift         # Firebase Auth wrapper
│   ├── LoginView.swift
│   ├── StudentRegisterView.swift
│   ├── EmployerRegisterView.swift
│   └── UserTypeSelectionView.swift
│
├── Student/                       # Student-specific features
│   ├── StudentHomeView.swift
│   ├── StudentSearchView.swift
│   ├── StudentApplicationsView.swift
│   ├── StudentProfileView.swift
│   └── [Other student views]
│
├── Employer/                      # Employer-specific features
│   ├── EmployerHomeView.swift
│   ├── EmployerCreateJobView.swift
│   ├── EmployerJobsView.swift
│   ├── EmployerProfileView.swift
│   └── [Other employer views]
│
├── Models/                        # Data models
│   ├── JobModel.swift
│   ├── ApplicationModel.swift
│   ├── JobStatus.swift           # Job status enum
│   ├── ApplicationStatus.swift   # Application status enum
│   └── User.swift
│
├── ViewModels/                    # MVVM ViewModels
│   ├── StudentHomeViewModel.swift
│   ├── StudentSearchViewModel.swift
│   ├── EmployerHomeViewModel.swift
│   ├── JobCardViewModel.swift
│   └── [Other ViewModels]
│
├── Utils/                         # Utility classes
│   └── InputValidator.swift      # Input validation
│
├── AppState.swift                 # Global app state
├── RootView.swift                 # Navigation root
├── MainTabView.swift              # Tab navigation
├── StudWerkApp.swift              # App entry point
└── GoogleService-Info.plist      # Firebase configuration
```

## Key Features

### Student Features
- **Home Dashboard**: Featured jobs, nearby jobs, statistics
- **Job Search**: Advanced search with filters (category, date, location)
- **Applications**: Track application status (Pending, Accepted, Rejected)
- **Profile Management**: Edit profile, payment details, settings

### Employer Features
- **Dashboard**: Statistics (active jobs, applications, hired students, total spend)
- **Job Posting**: Create and manage job postings
- **Application Management**: Review, accept, or reject student applications
- **Profile Management**: Edit company information, VAT ID, settings

### Shared Features
- **Authentication**: Email/password login and registration
- **Session Persistence**: Automatic login on app restart
- **Input Validation**: Email, phone, IBAN, password validation
- **Real-time Updates**: Firestore listeners for live data

## Dependencies

The project uses **Swift Package Manager** for dependency management:

### Firebase SDK (via Swift Package Manager)
- **Firebase Core** (12.7.0+)
- **Firebase Authentication**
- **Firebase Firestore**
- **FirebaseFirestoreCombine-Community**

### Package Repository
- Repository: `https://github.com/firebase/firebase-ios-sdk`
- Minimum Version: 12.7.0

### Automatic Dependency Resolution

Dependencies are automatically resolved by Xcode when you open the project. If you need to manually resolve:

1. Go to **File → Packages → Resolve Package Versions**
2. Or clean build folder: **Product → Clean Build Folder** (Shift + Cmd + K)

## Firebase Collections Structure

```
users/
  {uid}/
    - email: String
    - userType: String ("student" | "employer")
    - createdAt: Timestamp

students/
  {uid}/
    - userID: String
    - name: String
    - phone: String
    - iban: String
    - address: String
    - createdAt: Timestamp

employers/
  {uid}/
    - userID: String
    - name: String
    - phone: String
    - address: String
    - vatID: String
    - createdAt: Timestamp

jobs/
  {jobID}/
    - employerID: String
    - jobTitle: String
    - jobDescription: String
    - payment: String
    - date: Timestamp
    - startTime: Timestamp
    - endTime: Timestamp
    - category: String
    - location: String
    - status: String ("open" | "closed" | "completed" | "filled")
    - createdAt: Timestamp

applications/
  {applicationID}/
    - studentID: String
    - jobID: String
    - employerID: String
    - status: String ("Pending" | "Accepted" | "Rejected")
    - appliedAt: Timestamp
    - jobTitle: String (denormalized)
    - jobPayment: String (denormalized)
    - jobLocation: String (denormalized)
    - jobDate: Timestamp (denormalized)
    - jobStartTime: Timestamp (denormalized)
    - jobEndTime: Timestamp (denormalized)
    - jobCategory: String (denormalized)
```

## Development Notes

### Code Style
- Follows SwiftUI best practices
- Uses MVVM architecture pattern
- Type-safe enums for status values
- Input validation for all user inputs

### Testing
- Currently no unit tests
- Manual testing recommended before deployment

### Known Limitations
- No pagination for job listings (loads all at once)
- No image upload functionality
- Location-based distance calculation not implemented
- Push notifications settings exist but not fully implemented

## Contributing

1. Follow the existing MVVM architecture
2. Create ViewModels for views with business logic
3. Use type-safe enums instead of strings where possible
4. Add input validation for user inputs
5. Follow Swift naming conventions

## Project Team

1. Deniz Gözcü
2. Emir Yalçinkaya
3. Ada Ugur Abur
4. Batu Keren Yildirim
