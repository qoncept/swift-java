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

import XCTest

final class OptionalMethodWrapJavaTests: XCTestCase {
  func testOptionalConveniencesQualifyTheOriginalMethod() async throws {
    let classpath = try await compileJava(
      """
      package com.example;
      class OptionalMethodCollision {
        public java.util.OptionalLong arg0(java.util.OptionalLong value) { return value; }
        public java.util.OptionalLong checked(java.util.OptionalLong value) throws java.io.IOException { return value; }
        public static java.util.OptionalLong staticValue(java.util.OptionalLong value) { return value; }
        public long accept(java.util.OptionalLong value) { return value.orElse(0); }
      }
      """
    )
    try assertWrapJavaOutput(
      javaClassNames: ["java.util.OptionalLong", "com.example.OptionalMethodCollision"],
      classNameMappings: ["java.util.OptionalLong": "JavaOptionalLong"],
      classpath: [classpath],
      expectedChunks: [
        "Optional(javaOptional: self.arg0(arg0.toJavaOptional()))",
        "Optional(javaOptional: try self.checked(arg0.toJavaOptional()))",
        "Optional(javaOptional: self.staticValue(arg0.toJavaOptional()))",
        "self.accept(arg0.toJavaOptional())",
      ]
    )
  }
}
