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

public class ProtocolExtensionTest {
    @Test
    void extensionHelpersUseJavaRequirements() {
        ExtensionMessageProvider provider = () -> "hello";
        assertEquals("[hello]|5|prefix|suffix", MySwiftLibrary.formatExtensionMessage(provider));
    }

    @Test
    void extensionHelpersReadTheProvidedJavaValue() {
        ExtensionMessageProvider provider = () -> "custom";
        assertEquals("[custom]|6|prefix|suffix", MySwiftLibrary.formatExtensionMessage(provider));
    }

    @Test
    void returnedBoxUsesTheSwiftImplementation() {
        try (var arena = SwiftArena.ofConfined()) {
            ExtensionMessageProvider provider = MySwiftLibrary.makeExtensionMessageProvider(arena);
            assertEquals("Swift", provider.message());
            assertEquals("[Swift]|5|prefix|suffix", MySwiftLibrary.formatExtensionMessage(provider));
        }
    }
}
