# Swift Email Validator

A simple, robust email validation library for Swift, inspired by WordPress's battle-tested validation logic. Designed to be lightweight, fast, and RFC-compliant while providing convenient Swift-native APIs.

## Features

- ✅ **RFC 5321/5322 compliant** validation
- ✅ **WordPress-inspired** logic (handles billions of emails)
- ✅ **Zero dependencies** - pure Swift
- ✅ **Comprehensive provider detection** - recognizes major email providers
- ✅ **Swift-native APIs** - feels natural in Swift code
- ✅ **High performance** - optimized for speed
- ✅ **Extensive test coverage** - 20+ test cases covering edge cases

## Installation

### Swift Package Manager

Add EmailValidator to your project using Xcode:

1. File → Add Package Dependencies
2. Enter: `https://github.com/arraypress/swift-email-validator`
3. Select your desired version

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/arraypress/swift-email-validator", from: "1.0.0")
]
```

## Quick Start

```swift
import EmailValidator

// Basic validation
"user@example.com".isEmail // true
"invalid-email".isEmail    // false

// Get normalized email (lowercased domain)
"User@EXAMPLE.COM".normalizedEmail // "User@example.com"

// Parse email components
"user@example.com".emailLocalPart // "user"
"user@example.com".emailDomain    // "example.com"

// Provider detection
"user@gmail.com".emailProvider          // "Gmail"
"user@gmail.com".isPersonalEmailProvider // true
"user@company.com".isPersonalEmailProvider // false
```

## Core APIs

### String Extensions

#### `isEmail: Bool`
Validates if the string is a properly formatted email address.

```swift
"test@example.com".isEmail  // true
"invalid".isEmail           // false
```

#### `normalizedEmail: String?`
Returns a normalized version with lowercased domain, or nil if invalid.

```swift
"User@EXAMPLE.COM".normalizedEmail // "User@example.com"
"invalid".normalizedEmail          // nil
```

#### `emailLocalPart: String?`
Extracts the username portion (before @).

```swift
"user.name@example.com".emailLocalPart // "user.name"
```

#### `emailDomain: String?`
Extracts the domain portion (after @).

```swift
"user@sub.example.com".emailDomain // "sub.example.com"
```

#### `emailProvider: String?`
Detects known email providers.

```swift
"user@gmail.com".emailProvider    // "Gmail"
"user@yahoo.com".emailProvider    // "Yahoo"
"user@company.com".emailProvider  // nil
```

#### `isPersonalEmailProvider: Bool`
Checks if the email is from a recognized personal email provider.

```swift
"user@gmail.com".isPersonalEmailProvider    // true
"user@company.com".isPersonalEmailProvider  // false
```

### Array Extensions

#### `validEmails: [String]`
Filters array to only valid email addresses.

```swift
let emails = ["valid@example.com", "invalid", "another@test.org"]
emails.validEmails // ["valid@example.com", "another@test.org"]
```

#### `normalizedEmails: [String]`
Returns normalized versions of all valid emails.

```swift
let emails = ["User@EXAMPLE.COM", "invalid", "test@DOMAIN.ORG"]
emails.normalizedEmails // ["User@example.com", "test@domain.org"]
```

#### `validEmailsIfAny: [String]?`
Get valid emails if any exist, nil otherwise.

```swift
let emails = ["valid@example.com", "invalid", "another@test.org"]
if let validEmails = emails.validEmailsIfAny {
    print("Found \(validEmails.count) valid emails")
} else {
    print("No valid emails found")
}
```

#### `normalizedEmailsIfAny: [String]?`
Get normalized emails if any exist, nil otherwise.

```swift
let emails = ["User@EXAMPLE.COM", "invalid", "test@DOMAIN.ORG"]
if let normalized = emails.normalizedEmailsIfAny {
    print("Normalized emails: \(normalized)")
    // Result: ["User@example.com", "test@domain.org"]
} else {
    print("No valid emails to normalize")
}
```

#### `hasValidEmails: Bool`
Check if the collection contains any valid emails.

```swift
let emails = ["valid@example.com", "invalid", "another@test.org"]
if emails.hasValidEmails {
    print("Processing valid emails...")
    processEmails(emails.validEmails)
}
```

### Collection Extensions

#### `validEmailCount: Int`
Counts valid email addresses in the collection.

```swift
["valid@example.com", "invalid", "another@test.org"].validEmailCount // 2
```

## Supported Email Providers

EmailValidator recognizes these major providers:

### Google
- Gmail (gmail.com, googlemail.com)

### Microsoft
- Outlook (outlook.com + regional variants, hotmail.com + regional variants, live.com + regional variants, msn.com)

### Yahoo
- Yahoo (yahoo.com, yahoo.co.uk, yahoo.ca, yahoo.de, yahoo.fr, yahoo.com.au, and more)

### Apple
- iCloud (icloud.com, me.com, mac.com)

### Privacy-Focused
- ProtonMail (protonmail.com, proton.me)
- Tutanota (tutanota.com, tutanota.de)
- Hey (hey.com)

### Other Major Providers
- AOL (aol.com + regional variants)
- Yandex (yandex.com, yandex.ru)
- Mail.Ru (mail.ru)

### European Providers
- GMX (gmx.de, gmx.com, gmx.net)
- Web.de (web.de)
- Orange (orange.fr, wanadoo.fr)
- Free (free.fr)
- La Poste (laposte.net)

### Asian Providers
- NetEase (163.com, 126.com)
- QQ Mail (qq.com)
- Naver (naver.com)
- Daum (daum.net)

### Business-Oriented
- Zoho (zoho.com, zoho.eu)

## Examples

### Form Validation

```swift
func validateEmailField(_ email: String) -> String? {
    guard email.isEmail else {
        return "Please enter a valid email address"
    }
    return nil
}
```

### User Registration

```swift
func processSignup(email: String) {
    guard let normalizedEmail = email.normalizedEmail else {
        showError("Invalid email address")
        return
    }
    
    if normalizedEmail.isPersonalEmailProvider {
        // Personal email - different onboarding flow
        showPersonalOnboarding()
    } else {
        // Business email - enterprise features
        showBusinessOnboarding()
    }
    
    // Store normalized email
    user.email = normalizedEmail
}
```

### Bulk Email Processing

```swift
func processEmailList(_ emails: [String]) {
    let validEmails = emails.validEmails
    let normalizedEmails = emails.normalizedEmails
    
    print("Found \(emails.validEmailCount) valid emails out of \(emails.count)")
    
    // Process each email
    for email in validEmails {
        if let provider = email.emailProvider {
            print("Email from \(provider): \(email)")
        }
    }
}
```

### Email Analytics

```swift
func analyzeEmailSignups(_ emails: [String]) {
    let validEmails = emails.validEmails
    let personalCount = validEmails.filter(\.isPersonalEmailProvider).count
    let businessCount = validEmails.count - personalCount
    
    print("Personal emails: \(personalCount)")
    print("Business emails: \(businessCount)")
    
    // Group by provider
    let grouped = Dictionary(grouping: validEmails) { $0.emailProvider ?? "Other" }
    for (provider, emails) in grouped {
        print("\(provider): \(emails.count) emails")
    }
}
```

### Optional Handling

```swift
func processEmails(_ emails: [String]) {
    // Use optional variants for cleaner code
    if let validEmails = emails.validEmailsIfAny {
        print("Processing \(validEmails.count) valid emails")
        
        if let normalized = emails.normalizedEmailsIfAny {
            // Work with normalized emails
            sendBulkEmail(to: normalized)
        }
    } else {
        print("No valid emails to process")
    }
    
    // Or use boolean check
    if emails.hasValidEmails {
        print("Found valid emails, proceeding...")
    }
}
```

## Performance

EmailValidator is optimized for performance:

- **Individual validation**: ~0.007ms per email
- **Bulk operations**: ~0.001ms per email in arrays
- **Zero allocations** for failed validations
- **Lazy evaluation** in collection operations

## Validation Rules

EmailValidator follows RFC 5321/5322 standards with these key rules:

### Email Structure
- Must contain exactly one @ symbol
- Local part (before @) max 64 characters
- Domain part (after @) max 253 characters
- Total email max 254 characters
- Minimum 6 characters total

### Local Part Rules
- No leading or trailing dots
- No consecutive dots
- ASCII characters only
- Allows: letters, numbers, and `!#$%&'*+-/=?^_`{|}~.`

### Domain Rules
- At least two parts separated by dots
- Each part max 63 characters
- No leading/trailing hyphens in domain parts
- Top-level domain must be at least 2 letters
- ASCII letters, numbers, and hyphens only

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 5.5+
- Xcode 13.0+

## Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

EmailValidator is available under the MIT license. See LICENSE for details.

## Credits

Validation logic inspired by WordPress's `is_email()` function, adapted for Swift with modern APIs and comprehensive provider detection.
