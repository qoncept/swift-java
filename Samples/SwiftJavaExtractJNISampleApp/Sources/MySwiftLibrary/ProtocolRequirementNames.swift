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

public protocol NamingCallback {
  func message() -> String
}

extension NamingCallback {
  public func message() -> String { "default" }
}

struct DefaultNamingCallback: NamingCallback {}

public func callNamingCallback(_ callback: some NamingCallback) -> String {
  callback.message()
}

public func makeNamingCallback() -> any NamingCallback { DefaultNamingCallback() }

public protocol NamingParent {
  var id: Int64 { get }
  func value(number: Int64) -> Int64
}

public protocol NamingChild: NamingParent {
  var tag: Int64 { get }
  func value(text: Int64) -> Int64
}

struct NamingValue: NamingChild {
  var id: Int64 { 1 }
  var tag: Int64 { 2 }
  func value(number: Int64) -> Int64 { number + 10 }
  func value(text: Int64) -> Int64 { text + 20 }
}

public func makeNamingChild() -> any NamingChild { NamingValue() }
