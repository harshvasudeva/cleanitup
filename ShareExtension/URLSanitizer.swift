//
//  URLSanitizer.swift
//  sanitizer
//
//  Created by Harsh Vasudeva on 19/02/26.
//

import Foundation

struct URLSanitizer {
    
    // MARK: - Configuration
    
    struct Settings {
        var aggressiveCleaning: Bool
        
        static let `default` = Settings(
            aggressiveCleaning: false
        )
    }
    
    // MARK: - Tracking Parameters
    
    /// Common tracking parameters to remove
    private static let trackingParameters: Set<String> = [
        // Google Analytics
        "utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content",
        "utm_name", "utm_cid", "utm_reader", "utm_referrer", "utm_social",
        "utm_viz_id", "utm_pubreferrer", "utm_swu",
        
        // Google Ads
        "gclid", "gclsrc", "dclid",
        
        // Facebook
        "fbclid", "fb_action_ids", "fb_action_types", "fb_source", "fb_ref",
        
        // Instagram
        "igshid", "igsh",
        
        // TikTok
        "tt_medium", "tt_content",
        
        // Twitter/X
        "twclid", "s",
        
        // LinkedIn
        "li_fat_id", "trk",
        
        // Mailchimp
        "mc_cid", "mc_eid",
        
        // Hubspot
        "_hsenc", "_hsmi", "__hssc", "__hstc", "__hsfp", "hsCtaTracking",
        
        // Marketo
        "mkt_tok",
        
        // Adobe
        "s_cid",
        
        // YouTube (non-essential)
        "si", "feature",
        
        // Amazon
        "ref_", "ref", "pf_rd_r", "pf_rd_p", "pf_rd_m", "pf_rd_s", "pf_rd_t", "pf_rd_i",
        
        // Others
        "msclkid", "yclid", "wickedid", "vero_id", "_openstat", "mbid"
    ]
    
    /// Aggressive cleaning: parameters that might be non-essential
    private static let aggressiveParameters: Set<String> = [
        "source", "ref", "share", "referrer", "campaign", "affiliate",
        "from", "via", "sr_share", "recruiter", "refId"
    ]
    
    // MARK: - Sanitization
    
    static func sanitize(url urlString: String, settings: Settings = .default) -> Result<SanitizedURL, SanitizerError> {
        // Extract URL from text if needed
        guard let extractedURL = extractURL(from: urlString) else {
            return .failure(.noValidURL)
        }
        
        guard var components = URLComponents(string: extractedURL) else {
            return .failure(.invalidURL)
        }
        
        let originalURL = extractedURL
        var removedParameters: [String] = []
        
        // Clean query parameters
        if let queryItems = components.queryItems, !queryItems.isEmpty {
            let cleanedItems = queryItems.filter { item in
                let shouldRemove = trackingParameters.contains(item.name) ||
                    (settings.aggressiveCleaning && aggressiveParameters.contains(item.name)) ||
                    item.name.hasPrefix("utm_") ||
                    item.name.hasPrefix("mc_")
                
                if shouldRemove {
                    removedParameters.append(item.name)
                }
                
                return !shouldRemove
            }
            
            components.queryItems = cleanedItems.isEmpty ? nil : cleanedItems
        }
        
        // Clean fragment identifiers (tracking after #)
        if let fragment = components.fragment {
            if fragment.hasPrefix("?") {
                // Some sites put query params in the fragment
                components.fragment = nil
                removedParameters.append("fragment")
            }
        }
        
        guard let cleanURL = components.url?.absoluteString else {
            return .failure(.sanitizationFailed)
        }
        
        let result = SanitizedURL(
            original: originalURL,
            sanitized: cleanURL,
            removedParameters: removedParameters,
            wasModified: !removedParameters.isEmpty
        )
        
        return .success(result)
    }
    
    // MARK: - URL Extraction
    
    private static func extractURL(from text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if it's already a URL
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
            return trimmed
        }
        
        // Try to detect URL in text
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed))
        
        if let match = matches?.first, let url = match.url {
            return url.absoluteString
        }
        
        // Try adding https://
        if !trimmed.isEmpty && trimmed.contains(".") {
            return "https://\(trimmed)"
        }
        
        return nil
    }
}

// MARK: - Result Types

struct SanitizedURL {
    let original: String
    let sanitized: String
    let removedParameters: [String]
    let wasModified: Bool
    
    var displayURL: String {
        sanitized
    }
    
    var summary: String {
        if wasModified {
            return "\(removedParameters.count) tracking parameter\(removedParameters.count == 1 ? "" : "s") removed"
        } else {
            return "No tracking parameters found"
        }
    }
}

enum SanitizerError: LocalizedError, Equatable {
    case noValidURL
    case invalidURL
    case sanitizationFailed
    
    var errorDescription: String? {
        switch self {
        case .noValidURL:
            return "No valid URL found"
        case .invalidURL:
            return "Invalid URL format"
        case .sanitizationFailed:
            return "Failed to sanitize URL"
        }
    }
}
