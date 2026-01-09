# StudWerk Project Analysis

## Project Overview

**StudWerk** is an iOS application built with SwiftUI and Firebase, designed as a job marketplace connecting students with employers for temporary/part-time work opportunities. The app supports two user types: **Students** (job seekers) and **Employers** (job posters).

## Architecture & Structure

### Technology Stack
- **Framework**: SwiftUI
- **Backend**: Firebase (Authentication, Firestore)
- **Language**: Swift
- **Platform**: iOS

### Project Structure
```
StudWerk/
├── Auth/                    # Authentication & Registration
├── Student/                 # Student-specific features
├── Employer/                # Employer-specific features
├── Models/                  # Data models
├── AppState.swift           # Global app state management
├── RootView.swift           # Navigation root
├── MainTabView.swift        # Tab-based navigation
└── StudWerkApp.swift        # App entry point
```

## Key Components

### 1. State Management
- **AppState**: Centralized state management using `ObservableObject`
  - Manages navigation flow (login → register → main)
  - Stores user session (uid, email, userType)
  - Handles screen transitions

### 2. Authentication System
- **AuthManager**: Singleton managing Firebase Authentication
  - Login functionality
  - Student registration (with IBAN)
  - Employer registration (with company address)
  - Logout functionality
- **User Data Structure**:
  - `users` collection: Basic user info (email, userType)
  - `students` collection: Student-specific data (name, phone, IBAN, address)
  - `employers` collection: Employer-specific data (name, phone, address, VAT ID)

### 3. Data Models

#### User Model
- Supports both student and employer types
- Optional fields for type-specific data (IBAN, VAT ID, addresses)

#### Job Model
- Contains job details: title, description, payment, date/time, location, category
- Status tracking: "open", "closed", "completed", etc.
- Links to employer via `employerID`

#### Application Model
- Represents student applications to jobs
- Stores snapshot of job data at application time
- Status: Pending, Accepted, Rejected, Completed
- Includes job details denormalized for performance

### 4. Manager Classes (Singleton Pattern)

#### JobManager
- Create, read, update, delete jobs
- Fetch jobs by status, employer, or all
- Handles date/time combination logic
- Includes fallback for Firestore index issues

#### ApplicationManager
- Apply to jobs (with duplicate prevention)
- Fetch applications by student, employer, or job
- Update application status
- Auto-reject other applications when one is accepted
- Complete jobs and withdraw applications

#### StudentManager & EmployerManager
- Profile update functionality
- Limited scope (only profile updates)

#### UserManager
- Push notification settings management

### 5. User Interfaces

#### Student Features
- **Home**: Featured jobs, nearby jobs, stats (applications, earnings, completed jobs)
- **Search**: Job search with filters
- **Applications**: View application status
- **Profile**: Profile management and settings

#### Employer Features
- **Home**: Dashboard with stats (active jobs, applications, hired students, total spend)
- **Post Job**: Create new job postings
- **My Jobs**: Manage posted jobs and view applications
- **Profile**: Profile and settings management

## Data Flow

### Registration Flow
1. User selects type (Student/Employer)
2. Fills registration form
3. Firebase Auth creates account
4. User document created in `users` collection
5. Type-specific document created in `students` or `employers` collection
6. Auto-login and navigate to main app

### Job Application Flow
1. Student browses/search jobs
2. Applies to job (ApplicationManager checks for duplicates)
3. Application created with status "Pending"
4. Employer reviews applications
5. Employer accepts/rejects
6. If accepted, other applications auto-rejected
7. Job can be marked as completed

## Firebase Collections Structure

```
users/
  {uid}/
    - email
    - userType
    - createdAt

students/
  {uid}/
    - userID
    - name
    - phone
    - iban
    - address
    - createdAt

employers/
  {uid}/
    - userID
    - name
    - phone
    - address
    - vatID
    - createdAt

jobs/
  {jobID}/
    - employerID
    - jobTitle
    - jobDescription
    - payment
    - date, startTime, endTime
    - category
    - location
    - status
    - createdAt

applications/
  {applicationID}/
    - studentID
    - jobID
    - employerID
    - status
    - appliedAt
    - jobTitle, jobPayment, jobLocation, etc. (denormalized)
```

## Strengths

1. **Clean Architecture**: Well-organized folder structure separating concerns
2. **Type Safety**: Strong use of Swift enums (UserType, ApplicationStatus)
3. **Error Handling**: Try-catch blocks and error enums (ApplicationError)
4. **State Management**: Centralized AppState for navigation and session
5. **Firebase Integration**: Proper use of Firestore with error handling
6. **UI/UX**: Modern SwiftUI design with consistent styling
7. **Business Logic**: Smart features like auto-rejecting other applications
8. **Data Denormalization**: Job data stored in applications for performance

## Issues & Areas for Improvement

### Critical Issues

1. **Missing ApplicationStatus Location**
   - `ApplicationStatus` enum is defined in `ApplicationCard.swift` (Student folder)
   - Should be in `Models/` directory for shared access
   - Currently duplicated or imported inconsistently

2. **Incomplete User Model Usage**
   - `User.swift` model exists but isn't fully utilized
   - Managers don't fetch/return User objects
   - Profile views likely don't use the User model

3. **Missing Company Name Resolution**
   - `Job.company` returns empty string
   - `Application.company` returns empty string
   - Should fetch from employers collection

4. **No Session Persistence**
   - App doesn't check for existing Firebase Auth session on launch
   - Users must login every time app restarts

5. **Error Handling Inconsistencies**
   - Some views show alerts, others print to console
   - No centralized error handling strategy

### Code Quality Issues

6. **Code Duplication**
   - Similar query logic repeated in JobManager and ApplicationManager
   - Date formatting logic duplicated across models
   - Fallback query logic repeated multiple times

7. **Missing Validation**
   - No email format validation
   - No phone number validation
   - No IBAN validation
   - No password strength requirements

8. **Hardcoded Values**
   - Status strings ("open", "closed") should be enums
   - Magic numbers in UI (padding, limits)

9. **Missing Features**
   - No job search/filtering implementation visible
   - No location-based distance calculation (marked as TODO)
   - No push notification implementation (only settings)
   - No image upload for profiles/jobs

10. **Performance Concerns**
    - No pagination for job listings
    - Fetching all applications/jobs at once
    - No caching mechanism

11. **Security Concerns**
    - No Firestore security rules visible
    - IBAN stored in plain text (sensitive data)
    - No input sanitization visible

12. **Testing**
    - No unit tests
    - No UI tests
    - No test coverage

### Architecture Improvements

13. **Repository Pattern**
    - Managers directly access Firestore
    - Should abstract data layer with repositories

14. **Dependency Injection**
    - Heavy use of singletons makes testing difficult
    - Should use protocol-based dependency injection

15. **View Models**
    - Views contain business logic
    - Should use MVVM pattern with ViewModels

16. **Navigation**
    - Uses NotificationCenter for navigation (fragile)
    - Should use proper navigation state management

## Recommendations

### High Priority

1. **Move ApplicationStatus to Models/**
   ```swift
   // Models/ApplicationStatus.swift
   enum ApplicationStatus: String, CaseIterable, Codable {
       case pending = "Pending"
       case accepted = "Accepted"
       case completed = "Completed"
       case rejected = "Rejected"
   }
   ```

2. **Implement Session Persistence**
   ```swift
   // In AppState or RootView
   .onAppear {
       if let user = Auth.auth().currentUser {
           // Fetch user type and navigate to main
       }
   }
   ```

3. **Add Company Name Resolution**
   - Cache employer names in memory
   - Fetch when needed and update Job/Application models

4. **Create JobStatus Enum**
   ```swift
   enum JobStatus: String, Codable {
       case open = "open"
       case closed = "closed"
       case completed = "completed"
       case filled = "filled"
   }
   ```

5. **Implement Input Validation**
   - Email regex validation
   - Phone number format validation
   - IBAN format validation
   - Password strength requirements

### Medium Priority

6. **Refactor to MVVM**
   - Create ViewModels for each major view
   - Move business logic out of views

7. **Add Pagination**
   - Implement cursor-based pagination for jobs/applications
   - Use Firestore's `startAfter` for pagination

8. **Implement Search**
   - Add search functionality to StudentSearchView
   - Use Firestore text search or Algolia

9. **Add Error Handling Service**
   - Centralized error handling
   - User-friendly error messages

10. **Add Loading States**
    - Consistent loading indicators
    - Skeleton screens for better UX

### Low Priority

11. **Add Unit Tests**
    - Test managers
    - Test view models
    - Test business logic

12. **Add UI Tests**
    - Test critical user flows
    - Test registration/login

13. **Implement Caching**
    - Cache user profile
    - Cache job listings
    - Use NSCache or similar

14. **Add Analytics**
    - Track user actions
    - Monitor app performance

15. **Improve Documentation**
    - Add code comments
    - Document API contracts
    - Add README with setup instructions

## Code Metrics

- **Total Swift Files**: ~40+
- **Managers**: 5 (Auth, Job, Application, Student, Employer, User)
- **Models**: 3 (User, Job, Application)
- **Views**: 30+ SwiftUI views
- **Firebase Collections**: 4 (users, students, employers, jobs, applications)

## Dependencies

- Firebase Core
- Firebase Authentication
- Firebase Firestore

## Conclusion

StudWerk is a well-structured iOS application with a clear separation of concerns and modern SwiftUI architecture. The core functionality is implemented, but there are opportunities for improvement in code organization, error handling, validation, and feature completeness. The app demonstrates good understanding of Firebase integration and SwiftUI patterns, but would benefit from refactoring to improve testability and maintainability.
