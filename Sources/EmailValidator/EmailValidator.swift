//
//  EmailValidator.swift
//  EmailValidator
//
//  Simple, robust email validation inspired by WordPress
//  Created on 26/07/2025.
//

import Foundation

// MARK: - String Extension

public extension String {
    
    /// Check if this string is a valid email address.
    ///
    /// Uses WordPress-style validation with proper RFC compliance
    /// but returns a simple boolean for easy use.
    ///
    /// ## Example
    /// ```swift
    /// if "user@example.com".isEmail {
    ///     print("Valid email!")
    /// }
    ///
    /// // Filter arrays
    /// let validEmails = emails.filter { $0.isEmail }
    /// ```
    var isEmail: Bool {
        return EmailValidator.isValid(self)
    }
    
    /// Get the normalized (lowercase domain) version of this email if valid.
    ///
    /// Returns nil if the email is invalid. The local part (before @) preserves
    /// its original case as per RFC standards, while the domain is lowercased.
    ///
    /// ## Example
    /// ```swift
    /// let normalized = "User@EXAMPLE.COM".normalizedEmail
    /// // Result: "User@example.com"
    /// ```
    var normalizedEmail: String? {
        guard EmailValidator.isValid(self) else { return nil }
        
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(separator: "@", maxSplits: 1)
        guard parts.count == 2 else { return nil }
        
        let local = String(parts[0])
        let domain = String(parts[1]).lowercased()
        
        return "\(local)@\(domain)"
    }
    
    /// Extract the local part (username) from the email address.
    ///
    /// Returns the part before the @ symbol, or nil if the email is invalid.
    ///
    /// ## Example
    /// ```swift
    /// let local = "user.name@example.com".emailLocalPart
    /// // Result: "user.name"
    /// ```
    var emailLocalPart: String? {
        guard EmailValidator.isValid(self) else { return nil }
        
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard let atIndex = trimmed.firstIndex(of: "@") else { return nil }
        
        return String(trimmed[..<atIndex])
    }
    
    /// Extract the domain part from the email address.
    ///
    /// Returns the part after the @ symbol, or nil if the email is invalid.
    ///
    /// ## Example
    /// ```swift
    /// let domain = "user@sub.example.com".emailDomain
    /// // Result: "sub.example.com"
    /// ```
    var emailDomain: String? {
        guard EmailValidator.isValid(self) else { return nil }
        
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard let atIndex = trimmed.firstIndex(of: "@") else { return nil }
        
        return String(trimmed[trimmed.index(after: atIndex)...]).lowercased()
    }
    
    /// Detect the email provider name from the domain.
    ///
    /// Returns a user-friendly provider name, or nil if not recognized.
    ///
    /// ## Example
    /// ```swift
    /// "user@gmail.com".emailProvider          // "Gmail"
    /// "user@outlook.com".emailProvider        // "Outlook"
    /// "user@company.com".emailProvider        // nil
    /// ```
    var emailProvider: String? {
        guard let domain = emailDomain else { return nil }
        
        let providerMap: [String: String] = [
            // Google
            "gmail.com": "Gmail",
            "googlemail.com": "Gmail",
            
            // Microsoft
            "outlook.com": "Outlook",
            "hotmail.com": "Outlook",
            "live.com": "Outlook",
            "msn.com": "Outlook",
            
            // Yahoo
            "yahoo.com": "Yahoo",
            "yahoo.co.uk": "Yahoo",
            "yahoo.ca": "Yahoo",
            "yahoo.de": "Yahoo",
            "yahoo.fr": "Yahoo",
            "yahoo.com.au": "Yahoo",
            
            // Apple
            "icloud.com": "iCloud",
            "me.com": "iCloud",
            "mac.com": "iCloud",
            
            // Other providers
            "aol.com": "AOL",
            "protonmail.com": "ProtonMail",
            "tutanota.com": "Tutanota",
            "yandex.com": "Yandex",
            "mail.ru": "Mail.Ru",
            
            // Asian providers
            "163.com": "NetEase",
            "126.com": "NetEase",
            "qq.com": "QQ Mail"
        ]
        
        return providerMap[domain]
    }
    
    /// Check if this is a recognized personal email provider.
    ///
    /// Returns true for well-known consumer email services.
    /// Business domains and unknown providers return false.
    ///
    /// ## Example
    /// ```swift
    /// "user@gmail.com".isPersonalEmailProvider        // true
    /// "user@company.com".isPersonalEmailProvider      // false
    /// "support@startup.io".isPersonalEmailProvider    // false
    /// ```
    var isPersonalEmailProvider: Bool {
        return emailProvider != nil
    }
}

// MARK: - Array Extensions

public extension Array where Element == String {
    
    /// Filter array to only valid email addresses.
    ///
    /// ## Example
    /// ```swift
    /// let emails = ["valid@example.com", "invalid", "another@test.org"]
    /// let valid = emails.validEmails
    /// // Result: ["valid@example.com", "another@test.org"]
    /// ```
    var validEmails: [String] {
        return filter { $0.isEmail }
    }
    
    /// Get normalized versions of all valid emails.
    ///
    /// Invalid emails are filtered out automatically.
    ///
    /// ## Example
    /// ```swift
    /// let emails = ["User@EXAMPLE.COM", "invalid", "test@DOMAIN.ORG"]
    /// let normalized = emails.normalizedEmails
    /// // Result: ["User@example.com", "test@domain.org"]
    /// ```
    var normalizedEmails: [String] {
        return compactMap { $0.normalizedEmail }
    }
}

// MARK: - Collection Extensions

public extension Collection where Element == String {
    
    /// Count valid email addresses in the collection.
    ///
    /// ## Example
    /// ```swift
    /// let emails = ["valid@example.com", "invalid", "another@test.org"]
    /// let count = emails.validEmailCount
    /// // Result: 2
    /// ```
    var validEmailCount: Int {
        return self.lazy.filter { $0.isEmail }.count
    }
}

// MARK: - Internal Validator

/// Internal email validator with WordPress-inspired validation logic.
internal struct EmailValidator {
    
    /// RFC 5321/5322 limits
    private static let maxEmailLength = 254
    private static let minEmailLength = 6
    private static let maxLocalLength = 64
    private static let maxDomainLength = 253
    private static let maxSubdomainLength = 63
    private static let minTopLevelDomainLength = 2
    
    /// Simple boolean validation following WordPress approach.
    ///
    /// This method implements the same validation logic as WordPress's is_email()
    /// function but adapted for Swift with proper Unicode handling.
    static func isValid(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Test for minimum length the email can be
        guard trimmed.count >= minEmailLength else { return false }
        
        // Test for maximum length (RFC 5321)
        guard trimmed.count <= maxEmailLength else { return false }
        
        // Test for an @ character after the first position
        guard let atIndex = trimmed.firstIndex(of: "@"),
              atIndex > trimmed.startIndex else { return false }
        
        // Ensure there's only one @ symbol
        guard trimmed.lastIndex(of: "@") == atIndex else { return false }
        
        // Split out the local and domain parts
        let local = String(trimmed[..<atIndex])
        let domain = String(trimmed[trimmed.index(after: atIndex)...])
        
        // Validate both parts
        return isValidLocal(local) && isValidDomain(domain)
    }
    
    /// Validate the local part (before @) of an email address.
    private static func isValidLocal(_ local: String) -> Bool {
        // Test for empty local part
        guard !local.isEmpty else { return false }
        
        // Test for length limits (RFC 5321) - this must be checked on the string length
        guard local.count <= maxLocalLength else { return false }
        
        // Test for leading/trailing periods
        guard !local.hasPrefix("."), !local.hasSuffix(".") else { return false }
        
        // Test for consecutive periods
        guard !local.contains("..") else { return false }
        
        // Test for valid characters - only ASCII characters allowed
        // RFC 5322: atext characters plus period for local part
        for char in local {
            // Ensure character is ASCII
            guard char.isASCII else { return false }
            
            // Check if character is in allowed set
            let isValidChar = char.isLetter || char.isNumber || "!#$%&'*+-/=?^_`{|}~.".contains(char)
            guard isValidChar else { return false }
        }
        
        return true
    }
    
    /// Validate the domain part (after @) of an email address.
    private static func isValidDomain(_ domain: String) -> Bool {
        // Test for empty domain
        guard !domain.isEmpty else { return false }
        
        // Test for length limits (RFC 5321)
        guard domain.count <= maxDomainLength else { return false }
        
        // Test for sequences of periods
        guard !domain.contains("..") else { return false }
        
        // Test for leading and trailing periods and whitespace
        let trimmedDomain = domain.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: ".")))
        guard trimmedDomain == domain else { return false }
        
        // Split the domain into subs
        let subs = domain.split(separator: ".")
        
        // Assume the domain will have at least two subs
        guard subs.count >= 2 else { return false }
        
        // Reasonable upper limit on subdomains
        guard subs.count <= 10 else { return false }
        
        // Loop through each sub
        for (index, sub) in subs.enumerated() {
            let isTopLevel = index == subs.count - 1
            guard isValidSubdomain(String(sub), isTopLevel: isTopLevel) else { return false }
        }
        
        return true
    }
    
    /// Validate a single subdomain.
    private static func isValidSubdomain(_ subdomain: String, isTopLevel: Bool) -> Bool {
        // Test for empty subdomain
        guard !subdomain.isEmpty else { return false }
        
        // Test for length limits
        guard subdomain.count <= maxSubdomainLength else { return false }
        
        // Test for leading and trailing hyphens and whitespace
        let trimmed = subdomain.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: "-")))
        guard trimmed == subdomain else { return false }
        
        if isTopLevel {
            // Top-level domain specific validation
            guard subdomain.count >= minTopLevelDomainLength else { return false }
            
            // TLD should only contain ASCII letters
            return subdomain.allSatisfy { $0.isLetter && $0.isASCII }
        } else {
            // Regular subdomain validation: ASCII alphanumeric and hyphens only
            return subdomain.allSatisfy { char in
                char.isASCII && (char.isLetter || char.isNumber || char == "-")
            }
        }
    }
}
