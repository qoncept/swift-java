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

import JExtractSwiftLib
import SwiftJavaConfigurationShared
import Testing

@Suite
struct JNIFoundationCallbackTests {
  var config: Configuration {
    var config = Configuration()
    config.enableJavaCallbacks = true
    return config
  }

  @Test(arguments: ["Foundation", "FoundationEssentials"])
  func wrappedFoundationValues(module: String) throws {
    for type in ["Data", "Date", "URL"] {
      let source = """
        import \(module)
        public protocol Callback { func transform(_ value: \(type)) -> \(type) }
        public func invoke(_ callback: some Callback, _ value: \(type)) -> \(type)
        """
      try assertOutput(
        input: source,
        config: config,
        .jni,
        .swift,
        expectedChunks: [
          "protocol SwiftJavaCallbackWrapper: Callback",
          "let valuePointer = UnsafeMutablePointer<\(type)>.allocate(capacity: 1)",
          "unwrapped$.as(JavaJNISwiftInstance.self)!.memoryAddress()",
        ]
      )
    }
  }

  @Test(arguments: ["Foundation", "FoundationEssentials"])
  func uuidValues(module: String) throws {
    let source = """
      import \(module)
      public protocol Callback { func transform(_ value: UUID) -> UUID }
      public func invoke(_ callback: some Callback, _ value: UUID) -> UUID
      """
    try assertOutput(
      input: source,
      config: config,
      .jni,
      .swift,
      expectedChunks: [
        "protocol SwiftJavaCallbackWrapper: Callback",
        "value.uuidString",
        "UUID(uuidString:",
      ],
      notExpectedChunks: ["let valuePointer = UnsafeMutablePointer<UUID>"]
    )
  }

  @Test(arguments: ["Foundation", "FoundationEssentials"])
  func optionalValues(module: String) throws {
    for type in ["Data", "Date"] {
      let source = """
        import \(module)
        public protocol Callback {
          func optional(_ value: \(type)?) -> \(type)?
        }
        public func invoke(_ callback: some Callback)
        """
      try assertOutput(
        input: source,
        config: config,
        .jni,
        .swift,
        detectChunkByInitialLines: 1,
        expectedChunks: [
          "protocol SwiftJavaCallbackWrapper: Callback",
          "Optional(javaOptional:",
          "toJavaOptional()",
        ]
      )
    }
  }
}
