//
//  RecentURLsManager.swift
//  sanitizer
//
//  Created by Harsh Vasudeva on 19/02/26.
//

import Foundation

struct CleanedURLRecord: Identifiable, Codable {
    let id: UUID
    let originalURL: String
    let cleanedURL: String
    let timestamp: Date
    let removedCount: Int
    
    init(id: UUID = UUID(), originalURL: String, cleanedURL: String, timestamp: Date = Date(), removedCount: Int) {
        self.id = id
        self.originalURL = originalURL
        self.cleanedURL = cleanedURL
        self.timestamp = timestamp
        self.removedCount = removedCount
    }
}

@Observable
class RecentURLsManager {
    
    static let shared = RecentURLsManager()
    
    private let maxRecords = 5
    private let storageKey = "recentCleanedURLs"
    private let appGroupID = "group.sic.sanitizer"

    private let defaults: UserDefaults

    var recentURLs: [CleanedURLRecord] = []

    private init() {
        self.defaults = UserDefaults(suiteName: "group.sic.sanitizer") ?? .standard
        loadRecents()
    }
    
    func addRecord(from sanitizedURL: SanitizedURL) {
        let record = CleanedURLRecord(
            originalURL: sanitizedURL.original,
            cleanedURL: sanitizedURL.sanitized,
            removedCount: sanitizedURL.removedParameters.count
        )
        
        // Add to beginning
        recentURLs.insert(record, at: 0)
        
        // Keep only the most recent
        if recentURLs.count > maxRecords {
            recentURLs = Array(recentURLs.prefix(maxRecords))
        }
        
        saveRecents()
    }
    
    func clearAll() {
        recentURLs.removeAll()
        saveRecents()
    }
    
    private func saveRecents() {
        if let encoded = try? JSONEncoder().encode(recentURLs) {
            defaults.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadRecents() {
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([CleanedURLRecord].self, from: data) {
            recentURLs = decoded
        }
    }
}
