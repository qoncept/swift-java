//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2026 Apple Inc. and the Swift.org project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift.org project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import SwiftExtract
import Testing

@Suite
struct ProtocolRequirementTests {
  @Test
  func distinguishesRequirementsFromExtensionMembers() throws {
    let result = try analyze(
      sources: [
        (
          "/fake/Source.swift",
          """
          public protocol Callback {
            init()
            func message() -> String
            var count: Int64 { get set }
            subscript(index: Int64) -> Int64 { get }
            static func make() -> Callback
          }
          extension Callback {
            public init(value: Int64) { self.init() }
            public func message() -> String { "default" }
            public func helper() {}
            public var length: Int64 { 0 }
          }
          public struct Plain {
            public init() {}
            public func message() -> String { "plain" }
            public var count: Int64 { 0 }
          }
          public func message() -> String { "global" }
          """
        )
      ],
      moduleName: "Test"
    )
    let callback = try #require(result.extractedTypes["Callback"])
    let messages = callback.methods.filter { $0.name == "message" }
    #expect(messages.count == 2)
    #expect(messages.filter(\.isProtocolRequirement).count == 1)
    #expect(callback.methods.first { $0.name == "helper" }?.isProtocolRequirement == false)
    #expect(callback.methods.first { $0.name == "make" }?.isProtocolRequirement == true)
    let count = callback.variables.filter { $0.name == "count" }
    #expect(count.count == 2)
    #expect(count.allSatisfy { $0.isProtocolRequirement })
    #expect(callback.variables.first { $0.name == "length" }?.isProtocolRequirement == false)
    #expect(callback.initializers.count == 2)
    #expect(callback.initializers.filter(\.isProtocolRequirement).count == 1)
    let subscripts = (callback.methods + callback.variables).filter { $0.apiKind == .subscriptGetter }
    #expect(subscripts.count == 1)
    #expect(subscripts.allSatisfy { $0.isProtocolRequirement })
    let plain = try #require(result.extractedTypes["Plain"])
    #expect((plain.methods + plain.variables + plain.initializers).allSatisfy { !$0.isProtocolRequirement })
    #expect(result.extractedGlobalFuncs.allSatisfy { !$0.isProtocolRequirement })
  }
}
