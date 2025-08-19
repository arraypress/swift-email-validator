//
//  String.swift
//  EmailValidator
//
//  Created by David Sherlock on 19/08/2025.
//

import Foundation

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
        guard let local = emailLocalPart,
              let domain = emailDomain else { return nil }
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
            // Google (only gmail.com and googlemail.com are valid for actual emails)
            "gmail.com": "Gmail",
            "googlemail.com": "Gmail",
            
            // Microsoft (has extensive regional variants)
            "outlook.com": "Outlook",
            "outlook.co.uk": "Outlook",
            "outlook.de": "Outlook",
            "outlook.fr": "Outlook",
            "outlook.it": "Outlook",
            "outlook.es": "Outlook",
            "outlook.com.au": "Outlook",
            "outlook.ca": "Outlook",
            "outlook.be": "Outlook",
            "outlook.com.ar": "Outlook",
            "outlook.com.br": "Outlook",
            "outlook.co.in": "Outlook",
            "outlook.co.jp": "Outlook",
            
            "hotmail.com": "Outlook",
            "hotmail.co.uk": "Outlook",
            "hotmail.de": "Outlook",
            "hotmail.fr": "Outlook",
            "hotmail.it": "Outlook",
            "hotmail.es": "Outlook",
            "hotmail.com.au": "Outlook",
            "hotmail.ca": "Outlook",
            "hotmail.com.br": "Outlook",
            "hotmail.co.jp": "Outlook",
            
            "live.com": "Outlook",
            "live.co.uk": "Outlook",
            "live.de": "Outlook",
            "live.fr": "Outlook",
            "live.it": "Outlook",
            "live.ca": "Outlook",
            "live.com.au": "Outlook",
            
            "msn.com": "Outlook",
            
            // Yahoo (extensive international presence)
            "yahoo.com": "Yahoo",
            "yahoo.co.uk": "Yahoo",
            "yahoo.ca": "Yahoo",
            "yahoo.de": "Yahoo",
            "yahoo.fr": "Yahoo",
            "yahoo.it": "Yahoo",
            "yahoo.es": "Yahoo",
            "yahoo.com.au": "Yahoo",
            "yahoo.co.jp": "Yahoo",
            "yahoo.com.br": "Yahoo",
            "yahoo.co.in": "Yahoo",
            "yahoo.com.mx": "Yahoo",
            
            // Apple
            "icloud.com": "iCloud",
            "me.com": "iCloud",
            "mac.com": "iCloud",
            
            // AOL (has some regional variants)
            "aol.com": "AOL",
            "aol.co.uk": "AOL",
            "aol.de": "AOL",
            "aol.fr": "AOL",
            
            // Privacy-focused
            "protonmail.com": "ProtonMail",
            "proton.me": "ProtonMail",
            "tutanota.com": "Tutanota",
            "tutanota.de": "Tutanota",
            "hey.com": "Hey",
            
            // Russian
            "yandex.com": "Yandex",
            "yandex.ru": "Yandex",
            "mail.ru": "Mail.Ru",
            
            // German providers
            "gmx.de": "GMX",
            "gmx.com": "GMX",
            "gmx.net": "GMX",
            "web.de": "Web.de",
            
            // French providers
            "orange.fr": "Orange",
            "wanadoo.fr": "Orange",
            "free.fr": "Free",
            "laposte.net": "La Poste",
            
            // Korean providers
            "naver.com": "Naver",
            "daum.net": "Daum",
            
            // Chinese providers
            "163.com": "NetEase",
            "126.com": "NetEase",
            "qq.com": "QQ Mail",
            
            // Business-oriented but common
            "zoho.com": "Zoho",
            "zoho.eu": "Zoho"
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
