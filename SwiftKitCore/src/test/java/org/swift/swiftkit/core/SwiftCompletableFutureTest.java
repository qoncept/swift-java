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

package org.swift.swiftkit.core;

import org.junit.jupiter.api.Test;
import java.util.concurrent.*;
import static org.junit.jupiter.api.Assertions.*;

public class SwiftCompletableFutureTest {
    @Test
    void mappingPreservesResultsAndAlreadyCompletedSources() {
        var source = new SwiftCompletableFuture<String>();
        var result = source.mapSwiftResult(String::length);
        source.complete("hello");
        assertEquals(5, result.join());
        assertEquals(5, source.mapSwiftResult(String::length).join());
        assertFalse(result.cancel(false));
    }

    @Test
    void mappingPreservesFailures() {
        var source = new SwiftCompletableFuture<String>();
        var result = source.mapSwiftResult(String::length);
        var error = new IllegalStateException("source failed");
        source.completeExceptionally(error);
        assertSame(error, assertThrows(CompletionException.class, result::join).getCause());
    }

    @Test
    void mappingPreservesConversionFailures() {
        var source = new SwiftCompletableFuture<String>();
        var error = new IllegalArgumentException("conversion failed");
        var result = source.mapSwiftResult(value -> { throw error; });
        source.complete("hello");
        assertSame(error, assertThrows(CompletionException.class, result::join).getCause());
    }

    @Test
    void cancellingMappedResultCancelsTheSource() {
        var source = new SwiftCompletableFuture<String>();
        var result = source.mapSwiftResult(String::length);
        assertTrue(result.cancel(false));
        assertTrue(result.isCancelled());
        assertTrue(source.isCancelled());
        assertTrue(result.cancel(true));
    }

    @Test
    void cancellingTheSourceCancelsTheMappedResult() {
        var source = new SwiftCompletableFuture<String>();
        var result = source.mapSwiftResult(String::length);
        source.cancel(false);
        assertTrue(result.isCancelled());
        assertThrows(CancellationException.class, result::join);
    }
}
