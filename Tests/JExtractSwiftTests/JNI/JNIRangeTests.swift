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
struct JNIRangeTests {
  @Test(arguments: [("Int32", "Integer"), ("Int64", "Long"), ("Double", "Double"), ("String", "String")])
  func rangeJavaBindings(bound: String, javaBound: String) throws {
    try assertOutput(
      input: "public func f(_ range: Range<\(bound)>) -> Range<\(bound)> {}",
      .jni,
      .java,
      detectChunkByInitialLines: 1,
      expectedChunks: [
        """
        public static org.swift.swiftkit.core.SwiftRange<java.lang.\(javaBound)> f(org.swift.swiftkit.core.SwiftRange<java.lang.\(javaBound)> range) {
          return SwiftModule.$f(Objects.requireNonNull(range, "range must not be null"));
        }
        """,
        "private static native org.swift.swiftkit.core.SwiftRange $f(org.swift.swiftkit.core.SwiftRange range);",
      ],
      notExpectedChunks: ["SwiftArena swiftArena"]
    )
  }

  @Test
  func rangeSwiftThunkChecksBounds() throws {
    try assertOutput(
      input: "public func f(_ range: Range<Int64>) -> Range<Int64> {}",
      .jni,
      .swift,
      detectChunkByInitialLines: 1,
      expectedChunks: [
        """
        public func Java_com_example_swift_SwiftModule__00024f__Lorg_swift_swiftkit_core_SwiftRange_2(environment: UnsafeMutablePointer<JNIEnv?>!, thisClass: jclass, range: jobject?) -> jobject? {
          let range$indirect = SwiftRangeBridge<JavaBoxableBridge<Int64>>.fromJavaObject(range, in: environment)
          guard let range$indirect = range$indirect else {
            return nil
          }
          return SwiftRangeBridge<JavaBoxableBridge<Int64>>.toJavaObject(SwiftModule.f(range$indirect), in: environment)
        }
        """
      ]
    )
  }

  @Test
  func rangeArgumentWithVoidResult() throws {
    try assertOutput(
      input: "public func f(_ range: Range<String>) {}",
      .jni,
      .swift,
      detectChunkByInitialLines: 1,
      expectedChunks: [
        """
        guard let range$indirect = range$indirect else {
          return
        }
        """,
        "SwiftModule.f(range$indirect)",
      ]
    )
  }

  @Test
  func rangeArgumentWithPrimitiveResult() throws {
    try assertOutput(
      input: "public func f(_ range: Range<Int32>) -> Int32 {}",
      .jni,
      .swift,
      detectChunkByInitialLines: 1,
      expectedChunks: [
        """
        guard let range$indirect = range$indirect else {
          return 0
        }
        """
      ]
    )
  }

  @Test(arguments: ["[Range<Int64>]", "Range<Int64>?", "(Range<Int64>, Int64)"])
  func unsupportedRangeContainersAreSkipped(type: String) throws {
    try assertOutput(
      input: "public func nestedRange(_ value: \(type)) {}",
      .jni,
      .java,
      expectedChunks: [],
      notExpectedChunks: ["nestedRange("]
    )
  }

  @Test
  func ffmDoesNotExportRange() throws {
    try assertOutput(
      input: "public func rangeOnly(_ value: Range<Int64>) -> Range<Int64> {}",
      .ffm,
      .java,
      expectedChunks: [],
      notExpectedChunks: ["rangeOnly("]
    )
  }
}
