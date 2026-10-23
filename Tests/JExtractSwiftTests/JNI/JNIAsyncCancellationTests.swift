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
struct JNIAsyncCancellationTests {
  @Test("CompletableFuture result conversion preserves Swift cancellation")
  func cancellationBridge_java() throws {
    try assertOutput(
      input: "public func wait() async throws -> Int64?",
      .jni,
      .java,
      expectedChunks: [
        "org.swift.swiftkit.core.SwiftCompletableFuture<java.lang.Long> future$ = new org.swift.swiftkit.core.SwiftCompletableFuture<java.lang.Long>();",
        "return future$.mapSwiftResult((futureResult$) -> {",
      ]
    )
  }

  @Test("The native future is bound to its Swift task")
  func cancellationBridge_swift() throws {
    try assertOutput(
      input: "public func wait() async throws -> Int64?",
      .jni,
      .swift,
      expectedChunks: [
        "SwiftJavaRuntimeSupport._JNIAsyncTask.bind(task!, to: result_future, in: environment)"
      ]
    )
  }

  @Test("Legacy Future mode retains its existing bridge")
  func legacyBridgeIsUnchanged() throws {
    var config = Configuration()
    config.asyncFuncMode = .legacyFuture
    try assertOutput(
      input: "public func wait() async -> Int64",
      config: config,
      .jni,
      .java,
      expectedChunks: ["return future$.thenApply((futureResult$) -> {"],
      notExpectedChunks: ["mapSwiftResult", "core.SwiftCompletableFuture"]
    )
    try assertOutput(
      input: "public func wait() async -> Int64",
      config: config,
      .jni,
      .swift,
      expectedChunks: ["_JNIMethodIDCache.SimpleCompletableFuture.complete"],
      notExpectedChunks: ["_JNIAsyncTask.bind"]
    )
  }
}
