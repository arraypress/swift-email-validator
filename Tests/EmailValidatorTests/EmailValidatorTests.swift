//
//  EmailValidatorTests.swift
//  EmailValidator
//
//  Comprehensive test suite for email validation
//  Created on 26/07/2025.
//

import XCTest
@testable import EmailValidator

final class EmailValidatorTests: XCTestCase {
    
    // MARK: - Valid Email Tests
    
    func testValidEmails() {
        let validEmails = [
            "test@example.com",
            "user.name@domain.co.uk",
            "first.last@subdomain.example.org",
            "user+tag@example.com",
            "test123@example123.com",
            "a@b.co",
            "very.long.email.address@very.long.domain.name.com",
            "user_name@example-domain.com",
            "test.email+tag@example.org",
            "simple@example.museum",
            "test@example-site.com",
            "user@sub.domain.example.com"
        ]
        
        for email in validEmails {
            XCTAssertTrue(email.isEmail, "Expected '\(email)' to be valid")
            XCTAssertNotNil(email.normalizedEmail, "Should return normalized email for '\(email)'")
        }
    }
    
    func testEmailsWithSpecialCharacters() {
        let specialEmails = [
            "test!@example.com",
            "user#test@example.com",
            "test$@example.com",
            "user%test@example.com",
            "test&user@example.com",
            "user'test@example.com",
            "test*user@example.com",
            "user+tag@example.com",
            "test-user@example.com",
            "user/test@example.com",
            "test=user@example.com",
            "user?test@example.com",
            "test^user@example.com",
            "user_test@example.com",
            "test`user@example.com",
            "user{test}@example.com",
            "test|user@example.com",
            "user~test@example.com"
        ]
        
        for email in specialEmails {
            XCTAssertTrue(email.isEmail, "Expected special character email '\(email)' to be valid")
        }
    }
    
    // MARK: - Invalid Email Tests
    
    func testInvalidEmails() {
        let invalidEmails = [
            "",                           // Empty
            "short",                      // Too short
            "no-at-symbol.com",          // No @ symbol
            "@example.com",              // No local part
            "user@",                     // No domain
            "user@@example.com",         // Multiple @ symbols
            "user@.com",                 // Domain starts with dot
            "user@com.",                 // Domain ends with dot
            "user@com",                  // No TLD
            ".user@example.com",         // Local starts with dot
            "user.@example.com",         // Local ends with dot
            "us..er@example.com",        // Consecutive dots in local
            "user@exam..ple.com",        // Consecutive dots in domain
            "user@example.",             // Domain ends with dot
            "user name@example.com",     // Space in local part
            "user@exam ple.com",         // Space in domain
            "user@example.c",            // TLD too short
            "user@-example.com",         // Domain starts with hyphen
            "user@example-.com",         // Domain ends with hyphen
            String(repeating: "a", count: 65) + "@example.com", // Local too long (65 chars)
            "user@" + String(repeating: "a", count: 250) + ".com" // Domain too long
        ]
        
        for email in invalidEmails {
            XCTAssertFalse(email.isEmail, "Expected '\(email)' to be invalid")
            XCTAssertNil(email.normalizedEmail, "Should return nil for invalid email '\(email)'")
        }
    }
    
    func testEmailLengthLimits() {
        // Test minimum length (6 characters: a@b.co)
        XCTAssertTrue("a@b.co".isEmail)
        XCTAssertFalse("a@b.c".isEmail) // Too short
        
        // Test maximum length (254 characters total)
        let longLocal = String(repeating: "a", count: 64)
        let longDomain = String(repeating: "a", count: 60) + ".com"
        let maxLengthEmail = longLocal + "@" + longDomain
        
        if maxLengthEmail.count <= 254 {
            XCTAssertTrue(maxLengthEmail.isEmail, "Maximum length email should be valid")
        }
        
        // Test over maximum length
        let tooLongEmail = String(repeating: "a", count: 200) + "@" + String(repeating: "b", count: 60) + ".com"
        XCTAssertFalse(tooLongEmail.isEmail, "Over-length email should be invalid")
    }
    
    // MARK: - Email Normalization Tests
    
    func testEmailNormalization() {
        let testCases = [
            ("Test@EXAMPLE.COM", "Test@example.com"),
            ("user@DOMAIN.ORG", "user@domain.org"),
            ("MixedCase@MixedDomain.NET", "MixedCase@mixeddomain.net"),
            ("local@SUB.DOMAIN.COM", "local@sub.domain.com")
        ]
        
        for (input, expected) in testCases {
            XCTAssertEqual(input.normalizedEmail, expected, "Normalization failed for '\(input)'")
        }
    }
    
    func testNormalizationWithWhitespace() {
        let emailsWithWhitespace = [
            " test@example.com ",
            "\tuser@domain.org\t",
            "\ntest@example.net\n",
            " user@example.com"
        ]
        
        for email in emailsWithWhitespace {
            let normalized = email.normalizedEmail
            XCTAssertNotNil(normalized, "Should handle whitespace in '\(email)'")
            XCTAssertFalse(normalized?.contains(" ") ?? true, "Normalized email should not contain spaces")
            XCTAssertFalse(normalized?.contains("\t") ?? true, "Normalized email should not contain tabs")
            XCTAssertFalse(normalized?.contains("\n") ?? true, "Normalized email should not contain newlines")
        }
    }
    
    // MARK: - Array Extension Tests
    
    func testArrayValidEmails() {
        let mixedEmails = [
            "valid@example.com",
            "invalid-email",
            "another@test.org",
            "not-an-email",
            "third@domain.net"
        ]
        
        let validEmails = mixedEmails.validEmails
        let expectedValid = ["valid@example.com", "another@test.org", "third@domain.net"]
        
        XCTAssertEqual(validEmails.count, 3, "Should find 3 valid emails")
        XCTAssertEqual(Set(validEmails), Set(expectedValid), "Should match expected valid emails")
    }
    
    func testArrayNormalizedEmails() {
        let mixedEmails = [
            "Test@EXAMPLE.COM",
            "invalid-email",
            "USER@domain.ORG",
            "not@email",
            "another@TEST.NET"
        ]
        
        let normalizedEmails = mixedEmails.normalizedEmails
        let expected = ["Test@example.com", "USER@domain.org", "another@test.net"]
        
        XCTAssertEqual(normalizedEmails.count, 3, "Should normalize 3 valid emails")
        XCTAssertEqual(Set(normalizedEmails), Set(expected), "Should match expected normalized emails")
    }
    
    func testCollectionValidEmailCount() {
        let emails = ["valid@example.com", "invalid", "another@test.org", "not-email", "third@domain.net"]
        
        XCTAssertEqual(emails.validEmailCount, 3, "Should count 3 valid emails")
        
        let noValidEmails = ["invalid", "not-email", "also-invalid"]
        XCTAssertEqual(noValidEmails.validEmailCount, 0, "Should count 0 valid emails")
        
        let allValidEmails = ["test@example.com", "user@domain.org"]
        XCTAssertEqual(allValidEmails.validEmailCount, 2, "Should count all emails as valid")
    }
    
    // MARK: - Real-World Email Tests
    
    func testRealWorldEmails() {
        let realWorldEmails = [
            // Common providers
            "user@gmail.com",
            "test@yahoo.com",
            "example@outlook.com",
            "contact@hotmail.com",
            
            // Business emails
            "support@company.co.uk",
            "info@business.org",
            "contact@startup.io",
            "hello@agency.net",
            
            // International domains
            "user@example.de",
            "test@domain.fr",
            "contact@site.jp",
            "info@company.au",
            
            // Subdomain emails
            "api@mail.example.com",
            "noreply@newsletter.company.org",
            "support@help.service.net"
        ]
        
        for email in realWorldEmails {
            XCTAssertTrue(email.isEmail, "Real-world email '\(email)' should be valid")
        }
    }
    
    func testCommonInvalidPatterns() {
        let commonInvalidPatterns = [
            "plainaddress",
            "@missinglocal.com",
            "missing@.com",
            "missing.domain@.com",
            "missing@domain@extra.com",
            "spaces in@email.com",
            "email@spaces in.com",
            "email@domain,com",
            "email@domain..com",
            ".email@domain.com",
            "email.@domain.com"
        ]
        
        for invalidEmail in commonInvalidPatterns {
            XCTAssertFalse(invalidEmail.isEmail, "Common invalid pattern '\(invalidEmail)' should be rejected")
        }
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceValidation() {
        let testEmails = Array(repeating: "test@example.com", count: 1000)
        
        measure {
            for email in testEmails {
                _ = email.isEmail
            }
        }
    }
    
    func testPerformanceArrayFiltering() {
        let mixedEmails = Array(repeating: ["valid@example.com", "invalid", "another@test.org"], count: 100).flatMap { $0 }
        
        measure {
            _ = mixedEmails.validEmails
        }
    }
    
    // MARK: - Email Parsing Tests
    
    func testEmailLocalPart() {
        let testCases = [
            ("user@example.com", "user"),
            ("first.last@domain.org", "first.last"),
            ("user+tag@example.net", "user+tag"),
            ("test123@sub.example.com", "test123"),
            ("invalid-email", nil),
            ("@example.com", nil),
            ("user@", nil)
        ]
        
        for (input, expected) in testCases {
            XCTAssertEqual(input.emailLocalPart, expected, "Local part extraction failed for '\(input)'")
        }
    }
    
    func testEmailDomain() {
        let testCases = [
            ("user@example.com", "example.com"),
            ("test@SUB.DOMAIN.ORG", "sub.domain.org"), // Should be lowercased
            ("user@single.net", "single.net"),
            ("test@multi.sub.example.co.uk", "multi.sub.example.co.uk"),
            ("invalid-email", nil),
            ("user@", nil),
            ("@example.com", nil)
        ]
        
        for (input, expected) in testCases {
            XCTAssertEqual(input.emailDomain, expected, "Domain extraction failed for '\(input)'")
        }
    }
    
    // MARK: - Email Provider Tests
    
    func testEmailProvider() {
        let providerTests = [
            ("user@gmail.com", "Gmail"),
            ("test@googlemail.com", "Gmail"),
            ("person@outlook.com", "Outlook"),
            ("user@hotmail.com", "Outlook"),
            ("test@yahoo.com", "Yahoo"),
            ("user@yahoo.co.uk", "Yahoo"),
            ("person@icloud.com", "iCloud"),
            ("user@me.com", "iCloud"),
            ("test@aol.com", "AOL"),
            ("person@protonmail.com", "ProtonMail"),
            ("user@tutanota.com", "Tutanota"),
            ("test@yandex.com", "Yandex"),
            ("user@mail.ru", "Mail.Ru"),
            ("test@163.com", "NetEase"),
            ("user@126.com", "NetEase"),
            ("person@qq.com", "QQ Mail"),
            ("user@company.com", nil), // Unknown provider
            ("invalid-email", nil)
        ]
        
        for (email, expectedProvider) in providerTests {
            XCTAssertEqual(email.emailProvider, expectedProvider, "Provider detection failed for '\(email)'")
        }
    }
    
    func testIsPersonalEmailProvider() {
        let personalEmails = [
            "user@gmail.com",
            "test@yahoo.com",
            "person@hotmail.com",
            "user@outlook.com",
            "test@icloud.com",
            "person@aol.com",
            "user@protonmail.com",
            "test@qq.com",
            "user@yandex.com",
            "test@mail.ru",
            "person@163.com"
        ]
        
        let businessEmails = [
            "contact@company.com",
            "support@startup.io",
            "info@business.org",
            "hello@agency.net",
            "sales@enterprise.co.uk"
        ]
        
        for email in personalEmails {
            XCTAssertTrue(email.isPersonalEmailProvider, "'\(email)' should be detected as personal")
        }
        
        for email in businessEmails {
            XCTAssertFalse(email.isPersonalEmailProvider, "'\(email)' should be detected as business")
        }
        
        // Invalid emails should return false
        XCTAssertFalse("invalid-email".isPersonalEmailProvider)
    }
    
    // MARK: - Edge Case Tests
    
    func testUnicodeEmails() {
        // Test basic ASCII requirement for now
        let unicodeEmails = [
            "tëst@example.com",      // Non-ASCII in local
            "test@ëxample.com",      // Non-ASCII in domain
            "tést@éxample.com"       // Non-ASCII in both
        ]
        
        for email in unicodeEmails {
            // Current implementation requires ASCII - this documents current behavior
            // In future, could be enhanced for internationalized domain names
            XCTAssertFalse(email.isEmail, "Unicode email '\(email)' currently not supported")
        }
    }
    
    func testCaseSensitivityInValidation() {
        let emailVariations = [
            "Test@Example.Com",
            "TEST@EXAMPLE.COM",
            "test@example.com",
            "TeSt@ExAmPlE.cOm"
        ]
        
        for email in emailVariations {
            XCTAssertTrue(email.isEmail, "Case variation '\(email)' should be valid")
            
            let normalized = email.normalizedEmail!
            XCTAssertTrue(normalized.hasSuffix("@example.com"), "Domain should be lowercased in normalized email")
        }
    }
    
    // MARK: - Whitespace Handling Tests
    
    func testWhitespaceHandling() {
        let emailsWithWhitespace = [
            ("  test@example.com  ", true),
            ("\tuser@domain.org\t", true),
            ("\ntest@example.net\n", true),
            ("test @example.com", false),  // Space in local
            ("test@ example.com", false),  // Space after @
            ("test@example .com", false),  // Space in domain
            ("test@example.com ", true),   // Trailing space (should be trimmed)
            (" test@example.com", true)    // Leading space (should be trimmed)
        ]
        
        for (email, shouldBeValid) in emailsWithWhitespace {
            XCTAssertEqual(email.isEmail, shouldBeValid, "Whitespace handling failed for '\(email)'")
        }
    }
}
