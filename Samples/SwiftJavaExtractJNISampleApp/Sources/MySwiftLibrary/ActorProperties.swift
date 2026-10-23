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

public protocol ActorIdentifier {
  var identifier: Int64 { get }
}

public actor IdentifiedActor: ActorIdentifier {
  public let identifier: Int64
  public let unwitnessed: Int64
  public var mutable: Int64 { identifier + 2 }
  public nonisolated var label: String { "actor" }

  public init(identifier: Int64) {
    self.identifier = identifier
    self.unwitnessed = identifier + 1
  }
}

public protocol SendableActorIdentifier: AnyObject, Sendable {
  var identifier: Int64 { get }
}

public actor SendableIdentifiedActor: SendableActorIdentifier {
  public let identifier: Int64

  public init(identifier: Int64) {
    self.identifier = identifier
  }
}
