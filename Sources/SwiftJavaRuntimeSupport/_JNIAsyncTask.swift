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

import SwiftJava

/// Owns the Swift task until its Java future completes or is cancelled.
public final class _JNIAsyncTask: Sendable {
  let task: Task<Void, Never>

  init(_ task: Task<Void, Never>) { self.task = task }

  private static let setTask = _JNIMethodIDCache.Method(name: "setSwiftTask", signature: "(J)V")
  private static let methods = _JNIMethodIDCache(
    className: "org/swift/swiftkit/core/SwiftCompletableFuture",
    methods: [setTask]
  )

  public static func bind(_ task: Task<Void, Never>, to future: jobject?, in environment: JNIEnvironment) {
    let handle = Unmanaged.passRetained(_JNIAsyncTask(task)).toOpaque()
    _ = environment.interface.CallVoidMethodA(
      environment,
      future,
      methods.methods[setTask]!,
      [jvalue(j: Int64(Int(bitPattern: handle)))]
    )
  }
}

#if compiler(>=6.3)
@used
#endif
@_cdecl("Java_org_swift_swiftkit_core_SwiftCompletableFuture_cancelSwiftTask")
public func cancelSwiftAsyncTask(environment: UnsafeMutablePointer<JNIEnv?>!, type: jclass, handle: jlong) {
  Unmanaged<_JNIAsyncTask>.fromOpaque(UnsafeRawPointer(bitPattern: Int(handle))!).takeUnretainedValue().task.cancel()
}

#if compiler(>=6.3)
@used
#endif
@_cdecl("Java_org_swift_swiftkit_core_SwiftCompletableFuture_releaseSwiftTask")
public func releaseSwiftAsyncTask(environment: UnsafeMutablePointer<JNIEnv?>!, type: jclass, handle: jlong) {
  Unmanaged<_JNIAsyncTask>.fromOpaque(UnsafeRawPointer(bitPattern: Int(handle))!).release()
}
