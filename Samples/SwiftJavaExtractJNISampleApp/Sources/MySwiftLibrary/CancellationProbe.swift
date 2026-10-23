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

public actor CancellationProbe {
  private var cancelled = false

  public init() {}

  public func waitForCancellation() async throws -> Int64 {
    try await suspend()
    return 1
  }

  public func waitForOptionalCancellation() async throws -> Int64? {
    try await suspend()
    return 1
  }

  public func wasCancelled() -> Bool { cancelled }

  private func suspend() async throws {
    do {
      try await Task.sleep(for: .seconds(60))
    } catch {
      cancelled = true
      throw error
    }
  }
}
