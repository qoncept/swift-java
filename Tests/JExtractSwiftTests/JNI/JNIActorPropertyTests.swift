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
import Testing

@Suite
struct JNIActorPropertyTests {
  static let source = """
    public protocol Identified { var identifier: Int64 { get } }
    public actor Record: Identified {
      public let identifier: Int64
      public let unwitnessed: Int64
      public var mutable: Int64
      public nonisolated var label: Int64 { 7 }
      public nonisolated(unsafe) var unsafeValue: Int64
    }
    """

  @Test
  func synchronousJavaProperties() throws {
    try assertOutput(
      input: Self.source,
      .jni,
      .java,
      expectedChunks: [
        "public long getIdentifier() {",
        "public long getLabel() {",
        "public long getUnsafeValue() {",
        "public void setUnsafeValue(long newValue) {",
        "public java.util.concurrent.CompletableFuture<java.lang.Long> getUnwitnessed() {",
        "public java.util.concurrent.CompletableFuture<java.lang.Long> getMutable() {",
        "public java.util.concurrent.CompletableFuture<java.lang.Void> setMutable(long newValue) {",
      ]
    )
  }

  @Test
  func synchronousWitnessDowncall() throws {
    try assertOutput(
      input: Self.source,
      .jni,
      .swift,
      expectedChunks: [
        "return (selfPointer$.pointee as any Identified).identifier.getJNILocalRefValue(in: environment)",
        "return selfPointer$.pointee.label.getJNILocalRefValue(in: environment)",
        "selfPointer$.pointee.unsafeValue = Int64(fromJNI: newValue, in: environment)",
        "let swiftResult$ = await selfPointer$.pointee.mutable",
      ],
      notExpectedChunks: [
        "await selfPointer$.pointee.identifier",
        "await selfPointer$.pointee.label",
      ]
    )
  }
}
