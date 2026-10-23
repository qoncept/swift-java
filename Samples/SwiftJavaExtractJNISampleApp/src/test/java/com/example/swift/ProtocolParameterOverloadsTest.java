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
import org.swift.swiftkit.core.SwiftArena;
import static org.junit.jupiter.api.Assertions.assertEquals;

public class ProtocolParameterOverloadsTest {
    @Test
    void overloadedInitializersAndMethodsAcceptJavaCallbacks() {
        OverloadedCallback callback = () -> 10;
        try (var arena = SwiftArena.ofConfined()) {
            var first = ProtocolParameterOverloads.init(callback, arena);
            var second = ProtocolParameterOverloads.init(callback, 5, arena);
            assertEquals(10, first.getResult());
            assertEquals(15, second.getResult());
            assertEquals(20, first.calculate(callback));
            assertEquals(27, second.calculate(callback, 2));
        }
    }
}
