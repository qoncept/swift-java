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
import static org.junit.jupiter.api.Assertions.assertEquals;

public class ProtocolRequirementNamesTest {
    @Test
    void javaCallbackOverridesTheDefaultImplementation() {
        NamingCallback callback = () -> "Java";
        assertEquals("Java", MySwiftLibrary.callNamingCallback(callback));
    }

    @Test
    void returnedBoxUsesTheDefaultImplementation() {
        try (var arena = SwiftArena.ofConfined()) {
            assertEquals("default", MySwiftLibrary.makeNamingCallback(arena).message());
        }
    }

    @Test
    void inheritedOverloadsDispatchToTheCorrectWitness() {
        try (var arena = SwiftArena.ofConfined()) {
            NamingChild child = MySwiftLibrary.makeNamingChild(arena);
            assertEquals(1, child.getId());
            assertEquals(2, child.getTag());
            assertEquals(13, child.value(3));
            assertEquals(23, child.valueText(3));
        }
    }
}
