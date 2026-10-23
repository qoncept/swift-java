//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift.org project authors
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
struct JNIProtocolDefaultMethodTests {
  private var config: Configuration {
    var config = Configuration()
    config.enableJavaCallbacks = true
    return config
  }

  private let source = """
    public protocol Methods {
      func seed() -> Int
      func add(_ value: Int) -> Int
      func total() -> Int
    }
    extension Methods {
      public func add(_ renamed: Int) -> Int { seed() + renamed }
      public func total() -> Int { add(2) }
    }
    """

  @Test("Requirement defaults become Java default methods")
  func javaDefaultMethods() throws {
    try assertOutput(
      input: source,
      config: config,
      .jni,
      .java,
      expectedChunks: [
        "public long seed();",
        "public default long add(long value) throws SwiftIntegerOverflowException {",
        "public default long total() {",
        "final class Methods$SwiftDefaults {",
        "return Methods$SwiftDefaults.__swiftDefault_Methods_0(this, value);",
      ],
      notExpectedChunks: ["public long add(long value);"]
    )
  }

  @Test("Default receivers omit their own witness and forward other requirements")
  func swiftDefaultReceivers() throws {
    try assertOutput(
      input: source,
      config: config,
      .jni,
      .swift,
      expectedChunks: [
        "private final class __swiftDefault_Methods_0_Receiver: Methods {",
        "let value = __swiftDefault_Methods_0_Receiver(base: receiver)",
        "return value.`add`(p0)",
        "return base.`total`()",
      ]
    )
  }

  @Test("Nested protocols retain qualified Java names")
  func nestedProtocols() throws {
    try assertOutput(
      input: """
        public enum Namespace {
          public protocol Parent { func seed() -> Int64 }
          public protocol Child: Parent { func message() -> String }
        }
        extension Namespace.Child { public func message() -> String { "default" } }
        """,
      config: config,
      .jni,
      .java,
      expectedChunks: [
        "public interface Child extends Namespace.Parent, SwiftDowncastable {",
        "public default java.lang.String message() {",
        "static final class Child$SwiftDefaults {",
      ]
    )
  }

  @Test("Refinements can supply defaults for inherited requirements")
  func refinedDefault() throws {
    let source = """
      public protocol Parent { func value() -> Int64 }
      public protocol Child: Parent {}
      extension Child { public func value() -> Int64 { 7 } }
      """
    try assertOutput(
      input: source,
      config: config,
      .jni,
      .java,
      expectedChunks: ["public default long value() {"]
    )
    try assertOutput(
      input: source,
      config: config,
      .jni,
      .swift,
      expectedChunks: ["return _javaChildInterface.value()"]
    )
  }

  @Test("Conditional defaults remain abstract")
  func conditionalDefaults() throws {
    try assertOutput(
      input: """
        public protocol Callback { func message() -> String }
        extension Callback where Self: AnyObject {
          public func message() -> String { "conditional" }
        }
        """,
      config: config,
      .jni,
      .java,
      expectedChunks: ["public java.lang.String message();"],
      notExpectedChunks: ["public default java.lang.String message", "$SwiftDefaults"]
    )
  }

  @Test("Disabled callbacks do not acquire default bridges")
  func disabledCallbacks() throws {
    var config = config
    config.enableJavaCallbacks = false
    try assertOutput(
      input: source,
      config: config,
      .jni,
      .java,
      expectedChunks: ["public long add(long value) throws SwiftIntegerOverflowException;"],
      notExpectedChunks: ["$SwiftDefaults", "public default long add"]
    )
  }
  @Test(
    "Unsupported and actor-isolated protocols retain abstract requirements",
    arguments: [
      "@MainActor public protocol Callback { func message() -> String }; extension Callback { public func message() -> String { \"default\" } }",
      "public protocol Callback { @MainActor func message() -> String }; extension Callback { @MainActor public func message() -> String { \"default\" } }",
      "public protocol Callback { func message() -> String }; @MainActor extension Callback { public func message() -> String { \"default\" } }",
      "public protocol Callback { func message() -> String; var value: Int64 { get } }; extension Callback { public func message() -> String { \"default\" } }",
      "public protocol Callback { func message() async -> String }; extension Callback { public func message() async -> String { \"default\" } }",
    ]
  )
  func unsupportedDefaults(source: String) throws {
    try assertOutput(
      input: source,
      config: config,
      .jni,
      .java,
      expectedChunks: [],
      notExpectedChunks: ["$SwiftDefaults", "public default java.lang.String message"]
    )
  }

}
