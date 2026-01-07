//
//  JobManager.swift
//  StudWerk
//
//  Created by Deniz Gözcü on 07.01.26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class JobManager {
    static let shared = JobManager()
    private init() {}
    
    private let db = Firestore.firestore()
    private var jobsRef: CollectionReference { db.collection("jobs") }
    private var employersRef: CollectionReference { db.collection("employers") }
    
    func createJob(
        employerID: String,
        jobTitle: String,
        jobDescription: String,
        payment: String,
        date: Date,
        startTime: Date,
        endTime: Date,
        category: String,
        location: String
    ) async throws -> String {
        // Combine date and times into proper Date objects
        let calendar = Calendar.current
        let jobDateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        
        var startDateTime = calendar.date(bySettingHour: startComponents.hour ?? 0,
                                         minute: startComponents.minute ?? 0,
                                         second: 0,
                                         of: date) ?? date
        var endDateTime = calendar.date(bySettingHour: endComponents.hour ?? 0,
                                       minute: endComponents.minute ?? 0,
                                       second: 0,
                                       of: date) ?? date
        
        // Create job document
        let jobData: [String: Any] = [
            "employerID": employerID,
            "jobTitle": jobTitle,
            "jobDescription": jobDescription,
            "payment": payment,
            "date": Timestamp(date: date),
            "startTime": Timestamp(date: startDateTime),
            "endTime": Timestamp(date: endDateTime),
            "category": category,
            "location": location,
            "createdAt": FieldValue.serverTimestamp(),
            "status": "open" // or "closed", "filled", etc.
        ]
        
        let docRef = try await jobsRef.addDocument(data: jobData)
        return docRef.documentID
    }
    
    func fetchJobs(status: String? = "open", limit: Int? = nil) async throws -> [Job] {
        print("🔍 JobManager: Fetching jobs with status: \(status ?? "any"), limit: \(limit?.description ?? "none")")
        
        var query: Query = jobsRef
        
        // Filter by status if provided
        if let status = status {
            query = query.whereField("status", isEqualTo: status)
        }
        
        // Try to order by createdAt, but if it fails (index issue), we'll sort in memory
        var snapshot: QuerySnapshot
        do {
            query = query.order(by: "createdAt", descending: true)
            
            // Apply limit if provided
            if let limit = limit {
                query = query.limit(to: limit)
            }
            
            snapshot = try await query.getDocuments()
        } catch {
            // If ordering fails (likely due to missing composite index), fetch without orderBy
            print("⚠️ JobManager: OrderBy failed, fetching without order: \(error.localizedDescription)")
            var fallbackQuery: Query = jobsRef
            if let status = status {
                fallbackQuery = fallbackQuery.whereField("status", isEqualTo: status)
            }
            if let limit = limit {
                fallbackQuery = fallbackQuery.limit(to: limit)
            }
            snapshot = try await fallbackQuery.getDocuments()
        }
        
        print("📊 JobManager: Found \(snapshot.documents.count) documents in Firestore")
        
        var jobs = try snapshot.documents.compactMap { document -> Job? in
            let data = document.data()
            
            guard
                let employerID = data["employerID"] as? String,
                let jobTitle = data["jobTitle"] as? String,
                let jobDescription = data["jobDescription"] as? String,
                let payment = data["payment"] as? String,
                let category = data["category"] as? String,
                let location = data["location"] as? String,
                let status = data["status"] as? String,
                let dateTimestamp = data["date"] as? Timestamp,
                let startTimeTimestamp = data["startTime"] as? Timestamp,
                let endTimeTimestamp = data["endTime"] as? Timestamp
            else {
                return nil
            }
            
            // Handle createdAt - it might be a server timestamp that hasn't resolved yet
            let createdAt: Date
            if let createdAtTimestamp = data["createdAt"] as? Timestamp {
                createdAt = createdAtTimestamp.dateValue()
            } else {
                createdAt = Date()
            }
            
            return Job(
                id: document.documentID,
                employerID: employerID,
                jobTitle: jobTitle,
                jobDescription: jobDescription,
                payment: payment,
                date: dateTimestamp.dateValue(),
                startTime: startTimeTimestamp.dateValue(),
                endTime: endTimeTimestamp.dateValue(),
                category: category,
                location: location,
                createdAt: createdAt,
                status: status
            )
        }
        
        // Sort by createdAt descending (newest first) if we fetched without orderBy
        jobs.sort { $0.createdAt > $1.createdAt }
        
        // Apply limit after sorting if needed (in case we used fallback query)
        if let limit = limit, jobs.count > limit {
            jobs = Array(jobs.prefix(limit))
        }
        
        print("✅ JobManager: Returning \(jobs.count) jobs")
        return jobs
    }
    
    func fetchJob(byID jobID: String) async throws -> Job? {
        let document = try await jobsRef.document(jobID).getDocument()
        
        guard let data = document.data(),
              document.exists else {
            return nil
        }
        
        guard
            let employerID = data["employerID"] as? String,
            let jobTitle = data["jobTitle"] as? String,
            let jobDescription = data["jobDescription"] as? String,
            let payment = data["payment"] as? String,
            let category = data["category"] as? String,
            let location = data["location"] as? String,
            let status = data["status"] as? String,
            let dateTimestamp = data["date"] as? Timestamp,
            let startTimeTimestamp = data["startTime"] as? Timestamp,
            let endTimeTimestamp = data["endTime"] as? Timestamp
        else {
            return nil
        }
        
        // Handle createdAt - it might be a server timestamp that hasn't resolved yet
        let createdAt: Date
        if let createdAtTimestamp = data["createdAt"] as? Timestamp {
            createdAt = createdAtTimestamp.dateValue()
        } else {
            createdAt = Date()
        }
        
        return Job(
            id: document.documentID,
            employerID: employerID,
            jobTitle: jobTitle,
            jobDescription: jobDescription,
            payment: payment,
            date: dateTimestamp.dateValue(),
            startTime: startTimeTimestamp.dateValue(),
            endTime: endTimeTimestamp.dateValue(),
            category: category,
            location: location,
            createdAt: createdAt,
            status: status
        )
    }
    
    func fetchJobsByEmployer(employerID: String, status: String? = nil) async throws -> [Job] {
        print("🔍 JobManager: Fetching jobs for employerID: \(employerID), status: \(status ?? "any")")
        
        var query: Query = jobsRef.whereField("employerID", isEqualTo: employerID)
        
        // Filter by status if provided
        if let status = status {
            query = query.whereField("status", isEqualTo: status)
        }
        
        // Try to order by createdAt, but if it fails (index issue), we'll sort in memory
        var snapshot: QuerySnapshot
        do {
            query = query.order(by: "createdAt", descending: true)
            snapshot = try await query.getDocuments()
        } catch {
            // If ordering fails (likely due to missing composite index), fetch without orderBy
            print("⚠️ JobManager: OrderBy failed, fetching without order: \(error.localizedDescription)")
            var fallbackQuery: Query = jobsRef.whereField("employerID", isEqualTo: employerID)
            if let status = status {
                fallbackQuery = fallbackQuery.whereField("status", isEqualTo: status)
            }
            snapshot = try await fallbackQuery.getDocuments()
        }
        
        print("📊 JobManager: Found \(snapshot.documents.count) documents in Firestore")
        
        var jobs = try snapshot.documents.compactMap { document -> Job? in
            let data = document.data()
            
            guard
                let employerID = data["employerID"] as? String,
                let jobTitle = data["jobTitle"] as? String,
                let jobDescription = data["jobDescription"] as? String,
                let payment = data["payment"] as? String,
                let category = data["category"] as? String,
                let location = data["location"] as? String,
                let status = data["status"] as? String,
                let dateTimestamp = data["date"] as? Timestamp,
                let startTimeTimestamp = data["startTime"] as? Timestamp,
                let endTimeTimestamp = data["endTime"] as? Timestamp
            else {
                return nil
            }
            
            // Handle createdAt - it might be a server timestamp that hasn't resolved yet
            let createdAt: Date
            if let createdAtTimestamp = data["createdAt"] as? Timestamp {
                createdAt = createdAtTimestamp.dateValue()
            } else {
                createdAt = Date()
            }
            
            return Job(
                id: document.documentID,
                employerID: employerID,
                jobTitle: jobTitle,
                jobDescription: jobDescription,
                payment: payment,
                date: dateTimestamp.dateValue(),
                startTime: startTimeTimestamp.dateValue(),
                endTime: endTimeTimestamp.dateValue(),
                category: category,
                location: location,
                createdAt: createdAt,
                status: status
            )
        }
        
        // Sort by createdAt descending (newest first) if we fetched without orderBy
        jobs.sort { $0.createdAt > $1.createdAt }
        
        print("✅ JobManager: Returning \(jobs.count) jobs")
        return jobs
    }
    
    func fetchEmployerCompanyName(employerID: String) async throws -> String? {
        let document = try await employersRef.document(employerID).getDocument()
        
        guard let data = document.data(),
              document.exists,
              let companyName = data["companyName"] as? String else {
            return nil
        }
        
        return companyName
    }
}
