//
//  SettingsManager.swift
//  sanitizer
//
//  Created by Harsh Vasudeva on 19/02/26.
//

import Foundation

@Observable
class SettingsManager {
    
    // MARK: - Shared Instance
    
    static let shared = SettingsManager()
    
    // MARK: - Settings Keys
    
    private enum Keys {
        static let aggressiveCleaning = "aggressiveCleaning"
    }
    
    // MARK: - UserDefaults
    
    private static let appGroupID = "group.sic.sanitizer"
    private let defaults: UserDefaults
    
    // MARK: - Properties
    
    var aggressiveCleaning: Bool {
        didSet {
            defaults.set(aggressiveCleaning, forKey: Keys.aggressiveCleaning)
        }
    }
    
    var urlSanitizerSettings: URLSanitizer.Settings {
        URLSanitizer.Settings(
            aggressiveCleaning: aggressiveCleaning
        )
    }
    
    // MARK: - Initialization
    
    private init() {
        self.defaults = UserDefaults(suiteName: SettingsManager.appGroupID) ?? .standard
        
        self.aggressiveCleaning = defaults.bool(forKey: Keys.aggressiveCleaning)
    }
}
