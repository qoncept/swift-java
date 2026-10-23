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

public protocol DefaultOperations {
  func seed() -> Int
  func add(_ value: Int) -> Int
  func total() -> Int
  func checked(_ shouldThrow: Bool) throws -> Int64
}

extension DefaultOperations {
  public func add(_ renamed: Int) -> Int { seed() + renamed }
  public func total() -> Int { add(2) }
  public func checked(_ shouldThrow: Bool) throws -> Int64 {
    if shouldThrow { throw GreeterError() }
    return Int64(total())
  }
}

public func callDefaultOperations(_ operations: some DefaultOperations) -> Int {
  operations.total()
}

public struct DefaultNamespace {
  public protocol Parent { func seed() -> Int }
  public protocol Child: Parent { func extra() -> Int }
}

extension DefaultNamespace.Child {
  public func extra() -> Int { seed() + 3 }
}

public func callNestedDefaults(_ child: some DefaultNamespace.Child) -> Int {
  child.extra()
}

public protocol DefaultParent { func value() -> Int64 }
public protocol RefinedDefault: DefaultParent {}

extension RefinedDefault {
  public func value() -> Int64 { 7 }
}

public func callRefinedDefault(_ child: some RefinedDefault) -> Int64 {
  child.value()
}
