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
import java.util.concurrent.*;
import static org.junit.jupiter.api.Assertions.*;

public class AsyncCancellationTest {
    @Test
    void cancellingAConvertedScalarFutureCancelsTheSwiftTask() throws Exception {
        assertSwiftCancellation(false);
    }

    @Test
    void cancellingAnOutParameterResultCancelsTheSwiftTask() throws Exception {
        assertSwiftCancellation(true);
    }

    private void assertSwiftCancellation(boolean optional) throws Exception {
        try (var arena = SwiftArena.ofConfined()) {
            var probe = CancellationProbe.init(arena);
            CompletableFuture<?> future = optional
                ? probe.waitForOptionalCancellation() : probe.waitForCancellation();
            assertTrue(future.cancel(true));
            assertThrows(CancellationException.class, future::join);
            long deadline = System.nanoTime() + TimeUnit.SECONDS.toNanos(5);
            boolean observed = false;
            while (System.nanoTime() < deadline && !observed) {
                observed = probe.wasCancelled().get(1, TimeUnit.SECONDS);
                if (!observed) Thread.sleep(10);
            }
            assertTrue(observed, "Swift must observe cancellation of the returned future");
            assertTrue(future.cancel(false));
        }
    }

    @Test
    void completedTasksCanBeBoundAndReleasedImmediately() throws Exception {
        for (int i = 0; i < 100; i++) {
            var future = MySwiftLibrary.asyncSum(i, 1);
            assertEquals(i + 1L, future.get(5, TimeUnit.SECONDS));
            assertFalse(future.cancel(false));
        }
    }
}
