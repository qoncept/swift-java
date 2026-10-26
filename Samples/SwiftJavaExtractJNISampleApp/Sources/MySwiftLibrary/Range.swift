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

public func makeInt64Range() -> Range<Int64> {
  -10..<20
}

public func int64Range(_ range: Range<Int64>) -> Range<Int64> {
  range
}

public func platformIntRange(_ range: Range<Int>) -> Range<Int> {
  range
}

public func uint64Range(_ range: Range<UInt64>) -> Range<UInt64> {
  range
}

public func int32Range(_ range: Range<Int32>) -> Range<Int32> {
  range
}

public func int64RangeContains(_ range: Range<Int64>, value: Int64) -> Bool {
  range.contains(value)
}

public func acceptInt64Range(_ range: Range<Int64>) {
}

public func multipleRanges(_ first: Range<Int64>, _ second: Range<Int64>) -> Int64 {
  first.lowerBound + second.lowerBound
}

public func doubleRange(_ range: Range<Double>) -> Range<Double> {
  range
}

public func stringRange(_ range: Range<String>) -> Range<String> {
  range
}

public func stringRangeIsEmpty(_ range: Range<String>) -> Bool {
  range.isEmpty
}

public struct RangeBound: Comparable {
  public let value: Int64

  public init(value: Int64) {
    self.value = value
  }

  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.value < rhs.value
  }
}

public func customBoundRange(_ range: Range<RangeBound>) -> Range<RangeBound> {
  range
}
