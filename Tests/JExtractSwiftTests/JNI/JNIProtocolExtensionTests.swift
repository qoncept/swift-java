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
struct JNIProtocolExtensionTests {
  private var config: Configuration {
    var config = Configuration()
    config.enableJavaCallbacks = true
    return config
  }

  private let declaration = """
    public protocol Callback {
      func message() -> String
    }
    """

  @Test("Extension methods are not Java callback requirements", arguments: [false, true])
  func extensionMethod_java(callbacks: Bool) throws {
    var config = config
    config.enableJavaCallbacks = callbacks
    try assertOutput(
      input: declaration + """
        \nextension Callback {
          public func decoratedMessage() -> String { "[\\(message())]" }
        }
        """,
      config: config,
      .jni,
      .java,
      expectedChunks: ["public java.lang.String message();"],
      notExpectedChunks: ["public java.lang.String decoratedMessage();"]
    )
  }

  @Test(
    "Extension helpers do not disable Java callbacks",
    arguments: [
      "public var length: Int64 { 0 }",
      "public static func prefix() -> String { \"[\" }",
      "public static var suffix: String { \"]\" }",
      "public init(value: Int64) { fatalError() }",
    ]
  )
  func extensionHelpers_java(member: String) throws {
    try assertOutput(
      input: declaration + "\nextension Callback { \(member) }",
      config: config,
      .jni,
      .java,
      detectChunkByInitialLines: 1,
      expectedChunks: [
        """
        public interface Callback extends SwiftDowncastable {
        ...
        public java.lang.String message();
        """
      ],
      notExpectedChunks: ["public long getLength();"]
    )
  }

  @Test("Swift callback wrappers inherit extension implementations")
  func extensionHelpers_swift() throws {
    try assertOutput(
      input: declaration + """
        \nextension Callback {
          public func decoratedMessage() -> String { "[\\(message())]" }
          public var length: Int64 { 0 }
        }
        public func call(_ callback: some Callback) -> String
        """,
      config: config,
      .jni,
      .swift,
      expectedChunks: [
        "protocol SwiftJavaCallbackWrapper: Callback",
        "func message() -> String",
      ],
      notExpectedChunks: [
        "public func decoratedMessage() -> String",
        "public var length: Int64",
      ]
    )
  }

  @Test("Returned protocol boxes only dispatch actual requirements")
  func existentialBox_java() throws {
    try assertOutput(
      input: declaration + """
        \nextension Callback {
          public func decoratedMessage() -> String { "[\\(message())]" }
          public var length: Int64 { 0 }
        }
        public func makeCallback() -> any Callback
        """,
      config: config,
      .jni,
      .java,
      expectedChunks: [
        "final class CallbackBox implements JNISwiftInstance, Callback",
        "public java.lang.String message()",
      ],
      notExpectedChunks: [
        "public java.lang.String decoratedMessage()",
        "public long getLength()",
      ]
    )
  }

  @Test(
    "Unsupported requirements still prevent Java implementations",
    arguments: [
      "var count: Int64 { get }",
      "static func make() -> Callback",
      "static var count: Int64 { get }",
      "init()",
    ]
  )
  func unsupportedRequirement_java(requirement: String) throws {
    try assertOutput(
      input: "public protocol Callback { func message() -> String; \(requirement) }",
      config: config,
      .jni,
      .java,
      expectedChunks: ["public interface Callback extends JNISwiftInstance, SwiftDowncastable"]
    )
  }
}
