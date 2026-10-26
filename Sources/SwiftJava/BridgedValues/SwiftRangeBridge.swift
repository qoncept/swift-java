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

import SwiftJavaJNICore

/// Bridges a half-open Swift range by copying its bounds into a Java `SwiftRange`.
///
/// Bounds are compared in Swift, rather than using Java's `Comparable`, since
/// the two languages can order the same values differently (notably strings).
public enum SwiftRangeBridge<BoundBridge: JobjectBridge> where BoundBridge.SwiftType: Comparable {
  public typealias SwiftType = Range<BoundBridge.SwiftType>

  /// Copy the bounds to a Java object. The result is a JNI local reference.
  public static func toJavaObject(_ value: SwiftType, in environment: JNIEnvironment) -> jobject? {
    guard let rangeClass = environment.interface.FindClass(environment, "org/swift/swiftkit/core/SwiftRange") else { return nil }
    defer { environment.interface.DeleteLocalRef(environment, rangeClass) }
    guard let initializer = environment.interface.GetMethodID(environment, rangeClass, "<init>", "(Ljava/lang/Object;Ljava/lang/Object;)V") else { return nil }
    guard let lower = BoundBridge.toJavaObject(value.lowerBound, in: environment),
      let upper = BoundBridge.toJavaObject(value.upperBound, in: environment)
    else { return nil }
    var arguments = [jvalue(), jvalue()]
    arguments[0].l = lower
    arguments[1].l = upper
    return environment.interface.NewObjectA(environment, rangeClass, initializer, &arguments)
  }

  /// Reconstruct a range, returning `nil` with a pending Java exception for invalid input.
  /// The caller must return to Java immediately when conversion fails.
  public static func fromJavaObject(_ object: jobject?, in environment: JNIEnvironment) -> SwiftType? {
    guard let object else {
      postException(in: environment, className: "java/lang/NullPointerException", message: "Range must not be null")
      return nil
    }
    guard let rangeClass = environment.interface.FindClass(environment, "org/swift/swiftkit/core/SwiftRange") else { return nil }
    defer { environment.interface.DeleteLocalRef(environment, rangeClass) }
    guard environment.interface.IsInstanceOf(environment, object, rangeClass) == JNI_TRUE else {
      postException(in: environment, className: "java/lang/IllegalArgumentException", message: "Expected SwiftRange")
      return nil
    }
    guard let lowerField = environment.interface.GetFieldID(environment, rangeClass, "lowerBound", "Ljava/lang/Object;"),
      let upperField = environment.interface.GetFieldID(environment, rangeClass, "upperBound", "Ljava/lang/Object;")
    else { return nil }
    let lowerObject = environment.interface.GetObjectField(environment, object, lowerField)
    defer { environment.interface.DeleteLocalRef(environment, lowerObject) }
    let upperObject = environment.interface.GetObjectField(environment, object, upperField)
    defer { environment.interface.DeleteLocalRef(environment, upperObject) }
    guard BoundBridge.isJavaObject(lowerObject, in: environment),
      BoundBridge.isJavaObject(upperObject, in: environment)
    else {
      postException(in: environment, className: "java/lang/IllegalArgumentException", message: "Range bounds have an unexpected Java type")
      return nil
    }
    let lower = BoundBridge.fromJavaObject(lowerObject, in: environment)
    let upper = BoundBridge.fromJavaObject(upperObject, in: environment)
    guard lower <= upper else {
      postException(in: environment, className: "java/lang/IllegalArgumentException", message: "Range requires lowerBound <= upperBound")
      return nil
    }
    return lower..<upper
  }

  private static func postException(in environment: JNIEnvironment, className: String, message: String) {
    guard let exceptionClass = environment.interface.FindClass(environment, className) else { return }
    defer { environment.interface.DeleteLocalRef(environment, exceptionClass) }
    _ = environment.interface.ThrowNew(environment, exceptionClass, message)
  }
}
