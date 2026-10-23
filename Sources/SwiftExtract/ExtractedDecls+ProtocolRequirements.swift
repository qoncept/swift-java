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

import SwiftSyntax

extension ExtractedFunc {
  /// Whether this declaration is a requirement in a protocol body, rather than
  /// an implementation or an additional member declared in an extension.
  public var isProtocolRequirement: Bool {
    var parent = swiftDecl.parent
    while let node = parent {
      if node.is(ProtocolDeclSyntax.self) { return true }
      if node.isProtocol(DeclGroupSyntax.self) { return false }
      parent = node.parent
    }
    return false
  }
}
