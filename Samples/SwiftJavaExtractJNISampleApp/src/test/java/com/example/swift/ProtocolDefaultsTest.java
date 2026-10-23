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

package com.example.swift;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class ProtocolDefaultsTest {
    @Test
    void javaCallbacksInheritSwiftDefaults() throws Exception {
        DefaultOperations operations = () -> 10;
        assertEquals(12, operations.add(2));
        assertEquals(12, operations.total());
        assertEquals(12, MySwiftLibrary.callDefaultOperations(operations));
        assertEquals(12, operations.checked(false));
        assertThrows(GreeterError.class, () -> operations.checked(true));
    }

    @Test
    void defaultsPreserveJavaOverridesOfOtherDefaultedRequirements() throws Exception {
        DefaultOperations operations = new DefaultOperations() {
            public long seed() { return 10; }
            public long add(long value) { return 100 + value; }
        };
        assertEquals(102, operations.total());
        assertEquals(102, operations.checked(false));
        assertEquals(102, MySwiftLibrary.callDefaultOperations(operations));
    }

    @Test
    void nestedProtocolsUseTheirInheritedJavaCallback() {
        DefaultNamespace.Child child = () -> 4;
        assertEquals(7, child.extra());
        assertEquals(7, MySwiftLibrary.callNestedDefaults(child));
        DefaultNamespace.Parent parent = child;
        assertEquals(4, parent.seed());
    }

    @Test
    void refinedProtocolsCanDefaultAnInheritedRequirement() {
        RefinedDefault child = new RefinedDefault() {};
        assertEquals(7, child.value());
        assertEquals(7, MySwiftLibrary.callRefinedDefault(child));
        DefaultParent parent = child;
        assertEquals(7, parent.value());
    }
}
