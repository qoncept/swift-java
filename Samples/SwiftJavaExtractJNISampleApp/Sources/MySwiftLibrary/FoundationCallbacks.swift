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

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

public protocol FoundationCallback {
  func data(_ value: Data) -> Data
  func date(_ value: Date) -> Date
  func url(_ value: URL) -> URL
  func uuid(_ value: UUID) -> UUID
}

public func invokeDataCallback(_ callback: some FoundationCallback, _ value: Data) -> Data {
  callback.data(value)
}

public func invokeDateCallback(_ callback: some FoundationCallback, _ value: Date) -> Date {
  callback.date(value)
}

public func invokeURLCallback(_ callback: some FoundationCallback, _ value: URL) -> URL {
  callback.url(value)
}

public func invokeUUIDCallback(_ callback: some FoundationCallback, _ value: UUID) -> UUID {
  callback.uuid(value)
}

public protocol OptionalFoundationCallback {
  func optionalData(_ value: Data?) -> Data?
  func optionalDate(_ value: Date?) -> Date?
}

public func invokeOptionalDataCallback(_ callback: some OptionalFoundationCallback, present: Bool) -> [UInt8] {
  let result = callback.optionalData(present ? Data([1, 2, 3]) : nil)
  return result.map(Array.init) ?? []
}

public func invokeOptionalDateCallback(_ callback: some OptionalFoundationCallback, present: Bool) -> Double {
  callback.optionalDate(present ? Date(timeIntervalSince1970: 1234.5) : nil)?.timeIntervalSince1970 ?? -1
}
