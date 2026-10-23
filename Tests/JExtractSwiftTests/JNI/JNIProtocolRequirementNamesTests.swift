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
struct JNIProtocolRequirementNamesTests {
  @Test("Default implementations do not rename Java requirements")
  func defaultImplementation_java() throws {
    var config = Configuration()
    config.enableJavaCallbacks = true
    try assertOutput(
      input: """
        public protocol Callback { func message() -> String }
        extension Callback { public func message() -> String { "default" } }
        public func makeCallback() -> any Callback
        """,
      config: config,
      .jni,
      .java,
      expectedChunks: ["public default java.lang.String message() {", "public java.lang.String message() {"],
      notExpectedChunks: ["message_()"]
    )
  }

  private let inheritedSource = """
    public protocol Parent {
      var id: Int64 { get }
      func value(number: Int64) -> Int64
    }
    public protocol Child: Parent {
      var tag: Int64 { get }
      func value(text: Int64) -> Int64
    }
    public func makeChild() -> any Child
    """

  @Test("Inherited box methods retain the declaring interface's names")
  func inheritedRequirements_java() throws {
    try assertOutput(
      input: inheritedSource,
      .jni,
      .java,
      expectedChunks: [
        "public long value(long number);",
        "public long valueText(long text);",
        "public long value(long number) {",
        "public long valueText(long text) {",
      ],
      notExpectedChunks: ["valueNumber("]
    )
  }

  @Test("Inherited box dispatch thunks use the same names as Java")
  func inheritedRequirements_swift() throws {
    try assertOutput(
      input: inheritedSource,
      .jni,
      .swift,
      expectedChunks: [
        "@_cdecl(\"Java_com_example_swift_ChildBox__00024value__JJJ\")",
        "@_cdecl(\"Java_com_example_swift_ChildBox__00024valueText__JJJ\")",
      ],
      notExpectedChunks: ["ChildBox__00024valueNumber__"]
    )
  }
}
