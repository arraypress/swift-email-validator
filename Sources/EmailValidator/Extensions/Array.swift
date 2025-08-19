//
//  Array.swift
//  EmailValidator
//
//  Created by David Sherlock on 19/08/2025.
//

import Foundation

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
    
    /// Get valid emails if any exist, nil otherwise.
    ///
    /// Returns an array of valid email addresses, or nil if no valid emails
    /// are found. This is useful when you want to avoid checking isEmpty
    /// and prefer optional handling.
    ///
    /// ## Example
    /// ```swift
    /// let emails = ["valid@example.com", "invalid", "another@test.org"]
    /// if let validEmails = emails.validEmailsIfAny {
    ///     print("Found \(validEmails.count) valid emails")
    /// } else {
    ///     print("No valid emails found")
    /// }
    /// ```
    var validEmailsIfAny: [String]? {
        let valid = validEmails
        return valid.isEmpty ? nil : valid
    }
    
    /// Get normalized emails if any exist, nil otherwise.
    ///
    /// Returns an array of normalized email addresses, or nil if no valid emails
    /// are found. Combines validation and normalization with optional handling.
    ///
    /// ## Example
    /// ```swift
    /// let emails = ["User@EXAMPLE.COM", "invalid", "test@DOMAIN.ORG"]
    /// if let normalized = emails.normalizedEmailsIfAny {
    ///     print("Normalized emails: \(normalized)")
    ///     // Result: ["User@example.com", "test@domain.org"]
    /// } else {
    ///     print("No valid emails to normalize")
    /// }
    /// ```
    var normalizedEmailsIfAny: [String]? {
        let normalized = normalizedEmails
        return normalized.isEmpty ? nil : normalized
    }
    
    /// Check if the collection contains any valid emails.
    ///
    /// Returns true if at least one email in the collection is valid,
    /// false otherwise. More readable than checking validEmailCount > 0.
    ///
    /// ## Example
    /// ```swift
    /// let emails = ["valid@example.com", "invalid", "another@test.org"]
    /// if emails.hasValidEmails {
    ///     print("Processing valid emails...")
    ///     processEmails(emails.validEmails)
    /// }
    /// ```
    var hasValidEmails: Bool {
        return contains { $0.isEmail }
    }
    
}
