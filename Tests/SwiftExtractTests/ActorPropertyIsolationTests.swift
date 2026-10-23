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
struct ActorPropertyIsolationTests {
  static let source = """
    public protocol Identified { var identifier: Int64 { get } }
    public protocol InheritedIdentifier: Identified {}
    @MainActor public protocol MainActorValue { var mainActorValue: Int64 { get } }
    public protocol AsyncValue { var asynchronous: Int64 { get async } }
    public protocol ThrowingValue { var throwing: Int64 { get throws } }
    public protocol ActorValue: Actor { var isolated: Int64 { get } }
    public actor Record: InheritedIdentifier, AsyncValue, ThrowingValue, ActorValue, MainActorValue {
      public let identifier: Int64
      public let asynchronous: Int64
      public let throwing: Int64
      public let isolated: Int64
      public let mainActorValue: Int64
      public let unwitnessed: Int64
      public var mutable: Int64
      public nonisolated var label: Int64 { 7 }
      public nonisolated(unsafe) var unsafeValue: Int64
    }
    """

  @Test
  func explicitNonisolatedAccessors() throws {
    let record = try record()
    let accessors = record.variables.filter { ["label", "unsafeValue"].contains($0.name) }
    #expect(accessors.count == 3)
    #expect(accessors.allSatisfy { $0.functionSignature.isNonisolated })
    #expect(accessors.allSatisfy { !$0.functionSignature.isImplicitlyAsync })
  }

  @Test
  func immutableSynchronousWitness() throws {
    let accessor = try #require(try record().variables.first { $0.name == "identifier" })
    #expect(accessor.functionSignature.nonisolatedWitnessProtocol?.asNominalTypeDeclaration?.name == "InheritedIdentifier")
    #expect(accessor.functionSignature.isNonisolated)
    #expect(!accessor.functionSignature.isImplicitlyAsync)
  }

  @Test
  func otherActorPropertiesRemainIsolated() throws {
    let accessors = try record().variables.filter {
      ["asynchronous", "throwing", "isolated", "mainActorValue", "unwitnessed", "mutable"].contains($0.name)
    }
    #expect(accessors.count == 7)
    for accessor in accessors {
      #expect(accessor.functionSignature.isImplicitlyAsync, "\(accessor.name) must remain isolated")
    }
  }

  @Test(arguments: ["AnyObject", "Swift.AnyObject", "Sendable", "Swift.Sendable", "AnyObject, Swift.Sendable"])
  func standardConstraintsPreserveSynchronousWitness(_ inheritance: String) throws {
    let source = """
      public protocol Identified: \(inheritance) { var identifier: Int64 { get } }
      public actor Record: Identified { public let identifier: Int64 }
      """
    let result = try analyze(sources: [("/fake/Source.swift", source)], moduleName: "Test")
    let record = try #require(result.extractedTypes.values.first { $0.swiftNominal.name == "Record" })
    let accessor = try #require(record.variables.first { $0.name == "identifier" })
    #expect(accessor.functionSignature.nonisolatedWitnessProtocol?.asNominalTypeDeclaration?.name == "Identified")
    #expect(!accessor.functionSignature.isImplicitlyAsync)
  }

  @Test
  func inheritedStandardConstraintsPreserveSynchronousWitness() throws {
    let source = """
      public protocol Identified: AnyObject, Sendable { var identifier: Int64 { get } }
      public protocol InheritedIdentifier: Identified {}
      public actor Record: InheritedIdentifier { public let identifier: Int64 }
      """
    let result = try analyze(sources: [("/fake/Source.swift", source)], moduleName: "Test")
    let record = try #require(result.extractedTypes.values.first { $0.swiftNominal.name == "Record" })
    let accessor = try #require(record.variables.first { $0.name == "identifier" })
    #expect(accessor.functionSignature.nonisolatedWitnessProtocol?.asNominalTypeDeclaration?.name == "InheritedIdentifier")
    #expect(!accessor.functionSignature.isImplicitlyAsync)
  }

  @Test
  func localSendableDoesNotBypassIsolation() throws {
    let source = """
      @MainActor public protocol Sendable {}
      public protocol Identified: Sendable { var identifier: Int64 { get } }
      public actor Record: Identified { public let identifier: Int64 }
      """
    let result = try analyze(sources: [("/fake/Source.swift", source)], moduleName: "Test")
    let record = try #require(result.extractedTypes.values.first { $0.swiftNominal.name == "Record" })
    let accessor = try #require(record.variables.first { $0.name == "identifier" })
    #expect(accessor.functionSignature.nonisolatedWitnessProtocol == nil)
    #expect(accessor.functionSignature.isImplicitlyAsync)
  }

  private func record() throws -> ExtractedNominalType {
    let result = try analyze(sources: [("/fake/Source.swift", Self.source)], moduleName: "Test")
    return try #require(result.extractedTypes.values.first { $0.swiftNominal.name == "Record" })
  }
}
