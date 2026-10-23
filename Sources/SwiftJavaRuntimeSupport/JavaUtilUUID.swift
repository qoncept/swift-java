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

import SwiftJava

/// The Java UUID value used by generated JNI callback bindings.
@JavaClass("java.util.UUID")
public class JavaUtilUUID: JavaObject {}

extension JavaClass<JavaUtilUUID> {
  @JavaStaticMethod
  public func fromString(_ value: String) -> JavaUtilUUID!
}
