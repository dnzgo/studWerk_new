# README

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

### 4. Manager Classes

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

## Dependencies

- Firebase Core
- Firebase Authentication
- Firebase Firestore
