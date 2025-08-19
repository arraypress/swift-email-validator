//
//  EmailValidator.swift
//  EmailValidator
//
//  Created by David Sherlock on 19/08/2025.
//

import Foundation

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
