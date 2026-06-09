# Swift Email Validator

A lightweight Swift library for validating, normalizing, and inspecting email addresses. Built on WordPress-inspired, RFC 5321/5322-aware validation logic, it exposes a clean set of `String`, `Array`, and `Collection` extensions so you can check, filter, and analyze emails with natural, expressive syntax.

## Features

- 🎯 **RFC-aware validation** — Enforces length limits, local/domain rules, subdomain checks, and TLD constraints for accurate results.
- ✅ **Simple boolean checks** — `"user@example.com".isEmail` returns a plain `Bool` with no setup required.
- 🔤 **Email normalization** — Lowercases the domain while preserving the local part's original case per RFC standards.
- ✂️ **Component extraction** — Pull out the local part and domain from any valid address.
- 🏷️ **Provider detection** — Identify 90+ consumer providers (Gmail, Outlook, Yahoo, iCloud, ProtonMail, and more) from the domain.
- 👤 **Personal vs. business** — Distinguish recognized personal email providers from custom/business domains.
- 📚 **Array filtering** — `validEmails`, `normalizedEmails`, and their `…IfAny` optional variants for batch handling.
- 🔢 **Collection counting** — `validEmailCount` and `hasValidEmails` for quick aggregate checks.
- 🧱 **Zero dependencies** — Pure Foundation, no third-party packages.
- ⚡ **Lightweight & fast** — Lazy filtering and minimal allocations for large collections.

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 6.1+
- Xcode 16.0+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/arraypress/swift-email-validator.git", from: "1.0.0")
]
```

## Usage

### Validating a single email

```swift
import EmailValidator

if "user@example.com".isEmail {
    print("Valid email!")
}

"invalid".isEmail        // false
"a@b.co".isEmail         // true
```

### Normalizing and extracting components

```swift
import EmailValidator

let normalized = "User@EXAMPLE.COM".normalizedEmail
// "User@example.com" (domain lowercased, local part preserved)

"user.name@example.com".emailLocalPart   // "user.name"
"user@sub.example.com".emailDomain       // "sub.example.com"
```

### Detecting providers

```swift
import EmailValidator

"user@gmail.com".emailProvider           // "Gmail"
"user@outlook.com".emailProvider         // "Outlook"
"user@company.com".emailProvider         // nil

"user@gmail.com".isPersonalEmailProvider     // true
"support@startup.io".isPersonalEmailProvider // false
```

### Working with arrays and collections

```swift
import EmailValidator

let emails = ["User@EXAMPLE.COM", "invalid", "test@DOMAIN.ORG"]

emails.validEmails        // ["User@EXAMPLE.COM", "test@DOMAIN.ORG"]
emails.normalizedEmails   // ["User@example.com", "test@domain.org"]
emails.validEmailCount    // 2
emails.hasValidEmails     // true

// Optional variants return nil instead of an empty array
if let valid = emails.validEmailsIfAny {
    print("Found \(valid.count) valid emails")
}

if let normalized = emails.normalizedEmailsIfAny {
    print(normalized)
}
```

## How It Works

Validation trims whitespace, then enforces RFC 5321/5322 constraints:

- **Length** — between 6 and 254 characters overall; local part ≤ 64; domain ≤ 253.
- **Structure** — exactly one `@`, not in the first position, with non-empty local and domain parts.
- **Local part** — ASCII only, valid `atext` characters plus periods, no leading/trailing or consecutive dots.
- **Domain** — at least two labels, no consecutive dots, each subdomain ≤ 63 characters and alphanumeric/hyphen, and a TLD of ASCII letters at least 2 characters long.

## Testing

```bash
swift test
```

The test suite covers validation edge cases, normalization, component extraction, provider detection, and the array/collection helpers.

## License

MIT License — see LICENSE file for details.

## Author

Created by David Sherlock ([ArrayPress](https://github.com/arraypress)) in 2026.
