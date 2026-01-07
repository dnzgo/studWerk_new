//
//  ApplicationManager.swift
//  StudWerk
//
//  Created on 07.01.26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class ApplicationManager {
    static let shared = ApplicationManager()
    private init() {}
    
    private let db = Firestore.firestore()
    private var applicationsRef: CollectionReference { db.collection("applications") }
    private var jobsRef: CollectionReference { db.collection("jobs") }
    
    /// Check if a student has already applied to a job
    func hasAppliedToJob(jobID: String, studentID: String) async throws -> Bool {
        let query = applicationsRef
            .whereField("jobID", isEqualTo: jobID)
            .whereField("studentID", isEqualTo: studentID)
            .limit(to: 1)
        
        let snapshot = try await query.getDocuments()
        return !snapshot.documents.isEmpty
    }
    
    /// Apply to a job (prevents duplicates)
    func applyToJob(jobID: String, studentID: String) async throws -> String {
        print("🔍 ApplicationManager: Applying to job \(jobID) for student \(studentID)")
        
        // Check if already applied
        let alreadyApplied = try await hasAppliedToJob(jobID: jobID, studentID: studentID)
        if alreadyApplied {
            throw ApplicationError.alreadyApplied
        }
        
        // Fetch job details
        guard let job = try await JobManager.shared.fetchJob(byID: jobID) else {
            throw ApplicationError.jobNotFound
        }
        
        // Check if job is still open
        guard job.status == "open" else {
            throw ApplicationError.jobNotAvailable
        }
        
        // Create application document
        let applicationData: [String: Any] = [
            "studentID": studentID,
            "jobID": jobID,
            "employerID": job.employerID,
            "status": ApplicationStatus.pending.rawValue,
            "appliedAt": FieldValue.serverTimestamp(),
            "jobTitle": job.jobTitle,
            "jobPayment": job.payment,
            "jobLocation": job.location,
            "jobDate": Timestamp(date: job.date),
            "jobStartTime": Timestamp(date: job.startTime),
            "jobEndTime": Timestamp(date: job.endTime),
            "jobCategory": job.category
        ]
        
        let docRef = try await applicationsRef.addDocument(data: applicationData)
        print("✅ ApplicationManager: Created application \(docRef.documentID)")
        return docRef.documentID
    }
    
    /// Fetch applications by student ID
    func fetchApplicationsByStudent(studentID: String, status: ApplicationStatus? = nil) async throws -> [Application] {
        print("🔍 ApplicationManager: Fetching applications for student \(studentID), status: \(status?.rawValue ?? "any")")
        
        var query: Query = applicationsRef.whereField("studentID", isEqualTo: studentID)
        
        // Filter by status if provided
        if let status = status {
            query = query.whereField("status", isEqualTo: status.rawValue)
        }
        
        // Try to order by appliedAt, but if it fails (index issue), we'll sort in memory
        var snapshot: QuerySnapshot
        do {
            query = query.order(by: "appliedAt", descending: true)
            snapshot = try await query.getDocuments()
        } catch {
            // If ordering fails (likely due to missing composite index), fetch without orderBy
            print("⚠️ ApplicationManager: OrderBy failed, fetching without order: \(error.localizedDescription)")
            var fallbackQuery: Query = applicationsRef.whereField("studentID", isEqualTo: studentID)
            if let status = status {
                fallbackQuery = fallbackQuery.whereField("status", isEqualTo: status.rawValue)
            }
            snapshot = try await fallbackQuery.getDocuments()
        }
        
        print("📊 ApplicationManager: Found \(snapshot.documents.count) application documents")
        
        var applications = try snapshot.documents.compactMap { document -> Application? in
            let data = document.data()
            
            guard
                let studentID = data["studentID"] as? String,
                let jobID = data["jobID"] as? String,
                let employerID = data["employerID"] as? String,
                let status = data["status"] as? String,
                let jobTitle = data["jobTitle"] as? String,
                let jobPayment = data["jobPayment"] as? String,
                let jobLocation = data["jobLocation"] as? String,
                let jobDateTimestamp = data["jobDate"] as? Timestamp,
                let jobStartTimeTimestamp = data["jobStartTime"] as? Timestamp,
                let jobEndTimeTimestamp = data["jobEndTime"] as? Timestamp,
                let jobCategory = data["jobCategory"] as? String
            else {
                return nil
            }
            
            // Handle appliedAt - it might be a server timestamp that hasn't resolved yet
            let appliedAt: Date
            if let appliedAtTimestamp = data["appliedAt"] as? Timestamp {
                appliedAt = appliedAtTimestamp.dateValue()
            } else {
                appliedAt = Date()
            }
            
            return Application(
                id: document.documentID,
                studentID: studentID,
                jobID: jobID,
                employerID: employerID,
                status: status,
                appliedAt: appliedAt,
                jobTitle: jobTitle,
                jobPayment: jobPayment,
                jobLocation: jobLocation,
                jobDate: jobDateTimestamp.dateValue(),
                jobStartTime: jobStartTimeTimestamp.dateValue(),
                jobEndTime: jobEndTimeTimestamp.dateValue(),
                jobCategory: jobCategory
            )
        }
        
        // Sort by appliedAt descending (newest first) if we fetched without orderBy
        applications.sort { $0.appliedAt > $1.appliedAt }
        
        print("✅ ApplicationManager: Returning \(applications.count) applications")
        return applications
    }
    
    /// Fetch applications by job ID
    func fetchApplicationsByJob(jobID: String) async throws -> [Application] {
        print("🔍 ApplicationManager: Fetching applications for job \(jobID)")
        
        // Try to order by appliedAt, but if it fails (index issue), we'll sort in memory
        var snapshot: QuerySnapshot
        do {
            let query = applicationsRef
                .whereField("jobID", isEqualTo: jobID)
                .order(by: "appliedAt", descending: true)
            snapshot = try await query.getDocuments()
        } catch {
            // If ordering fails (likely due to missing composite index), fetch without orderBy
            print("⚠️ ApplicationManager: OrderBy failed, fetching without order: \(error.localizedDescription)")
            let fallbackQuery = applicationsRef.whereField("jobID", isEqualTo: jobID)
            snapshot = try await fallbackQuery.getDocuments()
        }
        
        print("📊 ApplicationManager: Found \(snapshot.documents.count) application documents for job \(jobID)")
        
        var applications = try snapshot.documents.compactMap { document -> Application? in
            let data = document.data()
            
            guard
                let studentID = data["studentID"] as? String,
                let jobID = data["jobID"] as? String,
                let employerID = data["employerID"] as? String,
                let status = data["status"] as? String,
                let jobTitle = data["jobTitle"] as? String,
                let jobPayment = data["jobPayment"] as? String,
                let jobLocation = data["jobLocation"] as? String,
                let jobDateTimestamp = data["jobDate"] as? Timestamp,
                let jobStartTimeTimestamp = data["jobStartTime"] as? Timestamp,
                let jobEndTimeTimestamp = data["jobEndTime"] as? Timestamp,
                let jobCategory = data["jobCategory"] as? String
            else {
                return nil
            }
            
            let appliedAt: Date
            if let appliedAtTimestamp = data["appliedAt"] as? Timestamp {
                appliedAt = appliedAtTimestamp.dateValue()
            } else {
                appliedAt = Date()
            }
            
            return Application(
                id: document.documentID,
                studentID: studentID,
                jobID: jobID,
                employerID: employerID,
                status: status,
                appliedAt: appliedAt,
                jobTitle: jobTitle,
                jobPayment: jobPayment,
                jobLocation: jobLocation,
                jobDate: jobDateTimestamp.dateValue(),
                jobStartTime: jobStartTimeTimestamp.dateValue(),
                jobEndTime: jobEndTimeTimestamp.dateValue(),
                jobCategory: jobCategory
            )
        }
        
        // Sort by appliedAt descending (newest first) if we fetched without orderBy
        applications.sort { $0.appliedAt > $1.appliedAt }
        
        print("✅ ApplicationManager: Returning \(applications.count) applications for job \(jobID)")
        return applications
    }
    
    /// Fetch applications by employer ID
    func fetchApplicationsByEmployer(employerID: String, status: ApplicationStatus? = nil) async throws -> [Application] {
        print("🔍 ApplicationManager: Fetching applications for employer \(employerID), status: \(status?.rawValue ?? "any")")
        
        var query: Query = applicationsRef.whereField("employerID", isEqualTo: employerID)
        
        // Filter by status if provided
        if let status = status {
            query = query.whereField("status", isEqualTo: status.rawValue)
        }
        
        // Try to order by appliedAt, but if it fails (index issue), we'll sort in memory
        var snapshot: QuerySnapshot
        do {
            query = query.order(by: "appliedAt", descending: true)
            snapshot = try await query.getDocuments()
        } catch {
            // If ordering fails (likely due to missing composite index), fetch without orderBy
            print("⚠️ ApplicationManager: OrderBy failed, fetching without order: \(error.localizedDescription)")
            var fallbackQuery: Query = applicationsRef.whereField("employerID", isEqualTo: employerID)
            if let status = status {
                fallbackQuery = fallbackQuery.whereField("status", isEqualTo: status.rawValue)
            }
            snapshot = try await fallbackQuery.getDocuments()
        }
        
        print("📊 ApplicationManager: Found \(snapshot.documents.count) application documents")
        
        var applications = try snapshot.documents.compactMap { document -> Application? in
            let data = document.data()
            
            guard
                let studentID = data["studentID"] as? String,
                let jobID = data["jobID"] as? String,
                let employerID = data["employerID"] as? String,
                let status = data["status"] as? String,
                let jobTitle = data["jobTitle"] as? String,
                let jobPayment = data["jobPayment"] as? String,
                let jobLocation = data["jobLocation"] as? String,
                let jobDateTimestamp = data["jobDate"] as? Timestamp,
                let jobStartTimeTimestamp = data["jobStartTime"] as? Timestamp,
                let jobEndTimeTimestamp = data["jobEndTime"] as? Timestamp,
                let jobCategory = data["jobCategory"] as? String
            else {
                return nil
            }
            
            let appliedAt: Date
            if let appliedAtTimestamp = data["appliedAt"] as? Timestamp {
                appliedAt = appliedAtTimestamp.dateValue()
            } else {
                appliedAt = Date()
            }
            
            return Application(
                id: document.documentID,
                studentID: studentID,
                jobID: jobID,
                employerID: employerID,
                status: status,
                appliedAt: appliedAt,
                jobTitle: jobTitle,
                jobPayment: jobPayment,
                jobLocation: jobLocation,
                jobDate: jobDateTimestamp.dateValue(),
                jobStartTime: jobStartTimeTimestamp.dateValue(),
                jobEndTime: jobEndTimeTimestamp.dateValue(),
                jobCategory: jobCategory
            )
        }
        
        // Sort by appliedAt descending (newest first) if we fetched without orderBy
        applications.sort { $0.appliedAt > $1.appliedAt }
        
        print("✅ ApplicationManager: Returning \(applications.count) applications")
        return applications
    }
    
    /// Update application status
    func updateApplicationStatus(applicationID: String, status: ApplicationStatus) async throws {
        print("🔍 ApplicationManager: Updating application \(applicationID) to status \(status.rawValue)")
        
        try await applicationsRef.document(applicationID).updateData([
            "status": status.rawValue
        ])
        
        print("✅ ApplicationManager: Updated application status")
        
        // If accepting an application, reject all other applications for the same job
        if status == .accepted {
            let application = try await fetchApplication(byID: applicationID)
            if let application = application {
                try await rejectOtherApplicationsForJob(jobID: application.jobID, acceptedApplicationID: applicationID)
            }
        }
    }
    
    /// Fetch a single application by ID
    private func fetchApplication(byID applicationID: String) async throws -> Application? {
        let document = try await applicationsRef.document(applicationID).getDocument()
        
        guard let data = document.data(),
              document.exists else {
            return nil
        }
        
        guard
            let studentID = data["studentID"] as? String,
            let jobID = data["jobID"] as? String,
            let employerID = data["employerID"] as? String,
            let status = data["status"] as? String,
            let jobTitle = data["jobTitle"] as? String,
            let jobPayment = data["jobPayment"] as? String,
            let jobLocation = data["jobLocation"] as? String,
            let jobDateTimestamp = data["jobDate"] as? Timestamp,
            let jobStartTimeTimestamp = data["jobStartTime"] as? Timestamp,
            let jobEndTimeTimestamp = data["jobEndTime"] as? Timestamp,
            let jobCategory = data["jobCategory"] as? String
        else {
            return nil
        }
        
        let appliedAt: Date
        if let appliedAtTimestamp = data["appliedAt"] as? Timestamp {
            appliedAt = appliedAtTimestamp.dateValue()
        } else {
            appliedAt = Date()
        }
        
        return Application(
            id: document.documentID,
            studentID: studentID,
            jobID: jobID,
            employerID: employerID,
            status: status,
            appliedAt: appliedAt,
            jobTitle: jobTitle,
            jobPayment: jobPayment,
            jobLocation: jobLocation,
            jobDate: jobDateTimestamp.dateValue(),
            jobStartTime: jobStartTimeTimestamp.dateValue(),
            jobEndTime: jobEndTimeTimestamp.dateValue(),
            jobCategory: jobCategory
        )
    }
    
    /// Reject all other applications for a job when one is accepted
    private func rejectOtherApplicationsForJob(jobID: String, acceptedApplicationID: String) async throws {
        print("🔍 ApplicationManager: Rejecting other applications for job \(jobID)")
        
        let snapshot = try await applicationsRef
            .whereField("jobID", isEqualTo: jobID)
            .whereField("status", isEqualTo: ApplicationStatus.pending.rawValue)
            .getDocuments()
        
        let batch = db.batch()
        var rejectedCount = 0
        
        for document in snapshot.documents {
            if document.documentID != acceptedApplicationID {
                batch.updateData(["status": ApplicationStatus.rejected.rawValue], forDocument: document.reference)
                rejectedCount += 1
            }
        }
        
        if rejectedCount > 0 {
            try await batch.commit()
            print("✅ ApplicationManager: Rejected \(rejectedCount) other applications")
        }
    }
    
    /// Complete a job (mark application as completed and job as completed)
    func completeJob(applicationID: String) async throws {
        print("🔍 ApplicationManager: Completing job for application \(applicationID)")
        
        // Get the application to find the jobID
        guard let application = try await fetchApplication(byID: applicationID) else {
            throw NSError(domain: "ApplicationManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Application not found"])
        }
        
        // Update application status to completed
        try await applicationsRef.document(applicationID).updateData([
            "status": ApplicationStatus.completed.rawValue
        ])
        
        // Update job status to completed
        try await JobManager.shared.updateJobStatus(jobID: application.jobID, status: "completed")
        
        print("✅ ApplicationManager: Completed job and application")
    }
    
    /// Withdraw an application (delete it)
    func withdrawApplication(applicationID: String) async throws {
        print("🔍 ApplicationManager: Withdrawing application \(applicationID)")
        
        try await applicationsRef.document(applicationID).delete()
        
        print("✅ ApplicationManager: Withdrew application")
    }
}

enum ApplicationError: LocalizedError {
    case alreadyApplied
    case jobNotFound
    case jobNotAvailable
    
    var errorDescription: String? {
        switch self {
        case .alreadyApplied:
            return "You have already applied to this job"
        case .jobNotFound:
            return "Job not found"
        case .jobNotAvailable:
            return "This job is no longer available"
        }
    }
}

