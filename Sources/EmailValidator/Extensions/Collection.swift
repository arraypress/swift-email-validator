//
//  Collection.swift
//  EmailValidator
//
//  Created by David Sherlock on 19/08/2025.
//

import Foundation

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
