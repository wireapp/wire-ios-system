//
// Wire
// Copyright (C) 2017 Wire Swiss GmbH
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


/// This is used to highlight memory leaks of critical objects.
/// In the code, add objects to the debugger by calling `MemoryReferenceDebugger.add`.
/// When running tests, you should check that `MemoryReferenceDebugger.aliveObjects` is empty
@objc public class MemoryReferenceDebugger: NSObject {
    
    public var references = [ReferenceAllocation]()
    
    static private var shared = MemoryReferenceDebugger()
    
    public static func register(_ object: AnyObject?, line: UInt = #line, file: StaticString = #file) {
        guard var object = object else { return }
        withUnsafePointer(to: &object) {
            shared.references.append(ReferenceAllocation(object: object, pointerAddress: $0.debugDescription, file: file.description, line: line))
        }
    }
    
    @objc public static func register(_ object: NSObject?, line: UInt, file: UnsafePointer<CChar>) {
        guard var object = object else { return }
        let fileString = String.init(cString: file)
        withUnsafePointer(to: &object) {
            shared.references.append(ReferenceAllocation(object: object, pointerAddress: $0.debugDescription, file: fileString, line: line))
        }
    }
    
    @objc static public func reset() {
        shared.references = []
    }
    
    @objc static public var aliveObjects: [AnyObject] {
        return shared.references.flatMap{ $0.object }
    }
    
    @objc static public var aliveObjectsDescription: String {
        return shared.references
            .filter{ $0.object != nil }
            .map{
                $0.description
            }.joined(separator: "/n")
    }
}

public struct ReferenceAllocation: CustomStringConvertible {
    
    public weak var object: AnyObject?
    public let pointerAddress: String
    public let file: String
    public let line: UInt
    
    public var isValid: Bool {
        return self.object != nil
    }
    
    public var description: String {
        guard let object = object else { return "<->" }
        return "\(type(of: object))[\(pointerAddress)], \(self.file):\(self.line)"
    }
    
}
