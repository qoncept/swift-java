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

public protocol OverloadedCallback {
  func value() -> Int64
}

public final class ProtocolParameterOverloads {
  public let result: Int64

  public init(callback: some OverloadedCallback) {
    result = callback.value()
  }

  public init(callback: some OverloadedCallback, extra: Int64) {
    result = callback.value() + extra
  }

  public func calculate(_ callback: some OverloadedCallback) -> Int64 {
    result + callback.value()
  }

  public func calculate(_ callback: some OverloadedCallback, extra: Int64) -> Int64 {
    result + callback.value() + extra
  }
}
