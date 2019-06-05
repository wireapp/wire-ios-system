////
// Wire
// Copyright (C) 2019 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import Foundation

/// Object can implement `PrivateStringConvertible` to allow creating the privacy-enabled object description.
/// Things to consider when implementing is to exclude any kind of personal information from the object description:
/// No user name, login, email, etc., or any kind of backend object ID.
public protocol PrivateStringConvertible {
    var privateDescription: String { get }
}

public struct SanitizedString: Equatable {
    var value: String
}

extension SanitizedString: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.value = value
    }
}

extension SanitizedString: ExpressibleByStringInterpolation {
    public init(stringInterpolation: SanitizedString) {
        self.value = stringInterpolation.value
    }
}

extension SanitizedString: StringInterpolationProtocol {
    
    public init(literalCapacity: Int, interpolationCount: Int) {
        self.value = ""
    }
    
    public mutating func appendLiteral(_ literal: StringLiteralType) {
        value += literal
    }
    
    public mutating func appendInterpolation<T: PrivateStringConvertible>(_ x: T) {
        value += x.privateDescription
    }
}

extension SanitizedString: CustomStringConvertible {
    public var description: String {
        return value
    }
}