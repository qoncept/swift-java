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

public protocol ExtensionMessageProvider {
  func message() -> String
}

extension ExtensionMessageProvider {
  public func decoratedMessage() -> String { "[\(message())]" }

  public var messageLength: Int64 { Int64(message().utf8.count) }

  public static var prefix: String { "prefix" }

  public static func suffix() -> String { "suffix" }
}

struct DefaultExtensionMessageProvider: ExtensionMessageProvider {
  func message() -> String { "Swift" }
}

public func formatExtensionMessage(_ provider: some ExtensionMessageProvider) -> String {
  "\(provider.decoratedMessage())|\(provider.messageLength)|\(type(of: provider).prefix)|\(type(of: provider).suffix())"
}

public func makeExtensionMessageProvider() -> any ExtensionMessageProvider {
  DefaultExtensionMessageProvider()
}
