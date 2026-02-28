//
//  URLSanitizerTests.swift
//  sanitizer Tests
//
//  Created by Harsh Vasudeva on 19/02/26.
//

import Testing
@testable import sanitizer

@Suite("URL Sanitizer Tests")
struct URLSanitizerTests {
    
    // MARK: - Basic Tracking Parameters
    
    @Test("Remove UTM parameters")
    func removeUTMParameters() {
        let input = "https://example.com/page?utm_source=twitter&utm_medium=social&utm_campaign=spring"
        let result = URLSanitizer.sanitize(url: input)
        
        guard case .success(let sanitized) = result else {
            Issue.record("Sanitization failed")
            return
        }
        
        #expect(sanitized.sanitized == "https://example.com/page")
        #expect(sanitized.wasModified == true)
        #expect(sanitized.removedParameters.count == 3)
    }
    
    @Test("Remove Facebook tracking")
    func removeFacebookTracking() {
        let input = "https://example.com/article?fbclid=IwAR12345"
        let result = URLSanitizer.sanitize(url: input)
        
        guard case .success(let sanitized) = result else {
            Issue.record("Sanitization failed")
            return
        }
        
        #expect(sanitized.sanitized == "https://example.com/article")
        #expect(sanitized.removedParameters.contains("fbclid"))
    }
    
    @Test("Remove Instagram tracking")
    func removeInstagramTracking() {
        let input = "https://example.com/post?igshid=abc123"
        let result = URLSanitizer.sanitize(url: input)
        
        guard case .success(let sanitized) = result else {
            Issue.record("Sanitization failed")
            return
        }
        
        #expect(sanitized.sanitized == "https://example.com/post")
    }
    
    // MARK: - Preserve Essential Parameters
    
    @Test("Preserve YouTube video ID")
    func preserveYouTubeVideoID() {
        let input = "https://youtube.com/watch?v=dQw4w9WgXcQ&si=tracking123"
        let result = URLSanitizer.sanitize(url: input)
        
        guard case .success(let sanitized) = result else {
            Issue.record("Sanitization failed")
            return
        }
        
        #expect(sanitized.sanitized.contains("v=dQw4w9WgXcQ"))
        #expect(!sanitized.sanitized.contains("si="))
    }
    
    @Test("Preserve search queries")
    func preserveSearchQueries() {
        let input = "https://example.com/search?q=swift&utm_source=google"
        let result = URLSanitizer.sanitize(url: input)
        
        guard case .success(let sanitized) = result else {
            Issue.record("Sanitization failed")
            return
        }
        
        #expect(sanitized.sanitized.contains("q=swift"))
        #expect(!sanitized.sanitized.contains("utm_"))
    }
    
    // MARK: - Multiple Tracking Parameters
    
    @Test("Remove multiple tracking parameters")
    func removeMultipleTracking() {
        let input = "https://example.com/page?utm_source=fb&fbclid=123&gclid=456&mc_cid=789"
        let result = URLSanitizer.sanitize(url: input)
        
        guard case .success(let sanitized) = result else {
            Issue.record("Sanitization failed")
            return
        }
        
        #expect(sanitized.sanitized == "https://example.com/page")
        #expect(sanitized.removedParameters.count == 4)
    }
    
    // MARK: - Edge Cases
    
    @Test("Handle URL with no parameters")
    func handleCleanURL() {
        let input = "https://example.com/page"
        let result = URLSanitizer.sanitize(url: input)
        
        guard case .success(let sanitized) = result else {
            Issue.record("Sanitization failed")
            return
        }
        
        #expect(sanitized.sanitized == input)
        #expect(sanitized.wasModified == false)
        #expect(sanitized.removedParameters.isEmpty)
    }
    
    @Test("Handle URL with only clean parameters")
    func handleOnlyCleanParameters() {
        let input = "https://example.com/page?id=123&lang=en"
        let result = URLSanitizer.sanitize(url: input)
        
        guard case .success(let sanitized) = result else {
            Issue.record("Sanitization failed")
            return
        }
        
        #expect(sanitized.sanitized == input)
        #expect(sanitized.wasModified == false)
    }
    
    @Test("Extract URL from plain text")
    func extractURLFromText() {
        let input = "Check out this link: https://example.com?utm_source=email"
        let result = URLSanitizer.sanitize(url: input)
        
        guard case .success(let sanitized) = result else {
            Issue.record("Sanitization failed")
            return
        }
        
        #expect(sanitized.sanitized == "https://example.com")
    }
    
    @Test("Handle invalid input")
    func handleInvalidInput() {
        let input = "not a url at all"
        let result = URLSanitizer.sanitize(url: input)
        
        guard case .failure(let error) = result else {
            Issue.record("Should have failed")
            return
        }
        
        #expect(error == .noValidURL)
    }
    
    // MARK: - Aggressive Cleaning
    
    @Test("Aggressive cleaning removes extra parameters")
    func aggressiveCleaningRemovesExtra() {
        let input = "https://example.com/page?id=123&ref=twitter&source=newsletter"
        let settings = URLSanitizer.Settings(aggressiveCleaning: true, expandShortenedLinks: false)
        let result = URLSanitizer.sanitize(url: input, settings: settings)
        
        guard case .success(let sanitized) = result else {
            Issue.record("Sanitization failed")
            return
        }
        
        #expect(sanitized.sanitized.contains("id=123"))
        #expect(!sanitized.sanitized.contains("ref="))
        #expect(!sanitized.sanitized.contains("source="))
    }
    
    // MARK: - Real World Examples
    
    @Test("Amazon product URL")
    func amazonProductURL() {
        let input = "https://amazon.com/dp/B08L5M9BTJ?ref_=nav_custrec_signin&th=1"
        let result = URLSanitizer.sanitize(url: input)
        
        guard case .success(let sanitized) = result else {
            Issue.record("Sanitization failed")
            return
        }
        
        #expect(!sanitized.sanitized.contains("ref_="))
        #expect(sanitized.sanitized.contains("th=1")) // Variation should be preserved
    }
    
    @Test("Twitter/X share URL")
    func twitterShareURL() {
        let input = "https://twitter.com/user/status/123?s=20"
        let result = URLSanitizer.sanitize(url: input)
        
        guard case .success(let sanitized) = result else {
            Issue.record("Sanitization failed")
            return
        }
        
        #expect(sanitized.sanitized == "https://twitter.com/user/status/123")
    }
    
    @Test("LinkedIn article URL")
    func linkedinArticleURL() {
        let input = "https://linkedin.com/feed/update/urn:li:activity:123?trk=public_profile"
        let result = URLSanitizer.sanitize(url: input)
        
        guard case .success(let sanitized) = result else {
            Issue.record("Sanitization failed")
            return
        }
        
        #expect(!sanitized.sanitized.contains("trk="))
    }
    
    // MARK: - Performance
    
    @Test("Sanitization completes quickly", .timeLimit(.milliseconds(300)))
    func sanitizationPerformance() async {
        let input = "https://example.com/page?utm_source=test&utm_medium=email&utm_campaign=promo&fbclid=123&gclid=456"
        
        _ = URLSanitizer.sanitize(url: input)
        
        // Test passes if completes within 300ms
    }
}

// MARK: - Test Data

extension URLSanitizerTests {
    /// Sample URLs for manual testing
    static let testURLs: [String: String] = [
        // Social Media
        "Facebook": "https://example.com/post?fbclid=IwAR1234567890",
        "Instagram": "https://example.com/post?igshid=abcdef123",
        "Twitter": "https://twitter.com/user/status/123?s=20",
        "LinkedIn": "https://linkedin.com/posts/activity-123?trk=public_profile",
        
        // E-commerce
        "Amazon": "https://amazon.com/dp/B08L5M9BTJ?ref_=nav_custrec_signin&pf_rd_r=ABC",
        "eBay": "https://ebay.com/itm/123456?mkevt=1&mkcid=2",
        
        // News & Media
        "News with UTM": "https://news.example.com/article?utm_source=twitter&utm_medium=social",
        "YouTube": "https://youtube.com/watch?v=dQw4w9WgXcQ&si=xyz123&feature=share",
        
        // Marketing
        "Mailchimp": "https://example.com/?mc_cid=123abc&mc_eid=456def",
        "HubSpot": "https://example.com/?_hsenc=abc&_hsmi=123",
        
        // Complex
        "Multiple Trackers": "https://example.com/page?id=1&utm_source=fb&fbclid=123&gclid=456&ref=twitter&q=search"
    ]
}
