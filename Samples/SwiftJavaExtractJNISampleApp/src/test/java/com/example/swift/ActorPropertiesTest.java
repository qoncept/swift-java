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

package com.example.swift;

import org.junit.jupiter.api.Test;
import org.swift.swiftkit.core.SwiftArena;

import java.util.concurrent.Future;

import static org.junit.jupiter.api.Assertions.*;

public class ActorPropertiesTest {
    @Test
    void nonisolatedPropertiesStaySynchronous() {
        try (var arena = SwiftArena.ofConfined()) {
            IdentifiedActor actor = IdentifiedActor.init(42, arena);
            long identifier = actor.getIdentifier();
            String label = actor.getLabel();
            assertEquals(42, identifier);
            assertEquals("actor", label);
        }
    }

    @Test
    void isolatedPropertiesStillReturnFutures() throws Exception {
        try (var arena = SwiftArena.ofConfined()) {
            IdentifiedActor actor = IdentifiedActor.init(42, arena);
            Future<Long> unwitnessed = actor.getUnwitnessed();
            Future<Long> mutable = actor.getMutable();
            assertEquals(43, unwitnessed.get());
            assertEquals(44, mutable.get());
        }
    }
}
