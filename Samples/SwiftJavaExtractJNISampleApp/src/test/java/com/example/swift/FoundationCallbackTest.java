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

import java.util.concurrent.atomic.AtomicBoolean;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

public class FoundationCallbackTest {
    private FoundationCallback callback(AtomicBoolean called) {
        return new FoundationCallback() {
            public Data data(Data value, SwiftArena arena) {
                called.set(true);
                assertArrayEquals(new byte[] {1, 2, 3}, value.toByteArray());
                return value;
            }
            public Date date(Date value, SwiftArena arena) {
                called.set(true);
                assertEquals(1234.5, value.getTimeIntervalSince1970());
                return value;
            }
            public URL url(URL value, SwiftArena arena) {
                called.set(true);
                return value;
            }
            public java.util.UUID uuid(java.util.UUID value) {
                called.set(true);
                assertEquals(java.util.UUID.fromString("12345678-1234-5678-9abc-def012345678"), value);
                return java.util.UUID.fromString("87654321-4321-8765-cba9-876543210fed");
            }
        };
    }

    @Test
    void dataRoundTrip() {
        try (var arena = SwiftArena.ofConfined()) {
            var called = new AtomicBoolean();
            Data input = Data.fromByteArray(new byte[] {1, 2, 3}, arena);
            Data result = MySwiftLibrary.invokeDataCallback(callback(called), input, arena);
            assertTrue(called.get());
            assertArrayEquals(input.toByteArray(), result.toByteArray());
        }
    }

    @Test
    void dateRoundTrip() {
        try (var arena = SwiftArena.ofConfined()) {
            var called = new AtomicBoolean();
            Date input = MySwiftLibrary.dateFromSeconds(1234.5, arena);
            Date result = MySwiftLibrary.invokeDateCallback(callback(called), input, arena);
            assertTrue(called.get());
            assertEquals(1234.5, result.getTimeIntervalSince1970());
        }
    }

    @Test
    void urlRoundTrip() {
        try (var arena = SwiftArena.ofConfined()) {
            var called = new AtomicBoolean();
            URL input = URL.init("https://example.com/callback", arena).orElseThrow();
            URL result = MySwiftLibrary.invokeURLCallback(callback(called), input, arena);
            assertTrue(called.get());
            assertEquals(input.getAbsoluteString(), result.getAbsoluteString());
        }
    }

    @Test
    void uuidRoundTripUsesJavaUtilUUID() {
        var called = new AtomicBoolean();
        var input = java.util.UUID.fromString("12345678-1234-5678-9abc-def012345678");
        var result = MySwiftLibrary.invokeUUIDCallback(callback(called), input);
        assertTrue(called.get());
        assertEquals(java.util.UUID.fromString("87654321-4321-8765-cba9-876543210fed"), result);
    }
    private OptionalFoundationCallback optionalCallback() {
        return new OptionalFoundationCallback() {
            public Optional<Data> optionalData(Optional<Data> value, SwiftArena arena) {
                value.ifPresent(data -> assertArrayEquals(new byte[] {1, 2, 3}, data.toByteArray()));
                return value;
            }
            public Optional<Date> optionalDate(Optional<Date> value, SwiftArena arena) {
                value.ifPresent(date -> assertEquals(1234.5, date.getTimeIntervalSince1970()));
                return value;
            }
        };
    }

    @Test
    void optionalValuesRoundTrip() {
        var callback = optionalCallback();
        assertArrayEquals(new byte[] {1, 2, 3}, MySwiftLibrary.invokeOptionalDataCallback(callback, true));
        assertArrayEquals(new byte[] {}, MySwiftLibrary.invokeOptionalDataCallback(callback, false));
        assertEquals(1234.5, MySwiftLibrary.invokeOptionalDateCallback(callback, true));
        assertEquals(-1, MySwiftLibrary.invokeOptionalDateCallback(callback, false));
    }

}
