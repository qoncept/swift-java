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

import java.util.concurrent.CompletableFuture;
import java.util.function.Function;

/** A JNI task future whose cancellation reaches the Swift task, including after result conversion. */
public final class SwiftCompletableFuture<T> extends CompletableFuture<T> {
    private final Object taskLock = new Object();
    private long taskHandle;
    private final Runnable cancelSource;

    public SwiftCompletableFuture() { this(null); }

    private SwiftCompletableFuture(Runnable cancelSource) { this.cancelSource = cancelSource; }

    public void setSwiftTask(long handle) {
        synchronized (taskLock) {
            if (!isDone()) { taskHandle = handle; return; }
        }
        if (isCancelled()) cancelSwiftTask(handle);
        releaseSwiftTask(handle);
    }

    @Override
    public boolean cancel(boolean mayInterruptIfRunning) {
        boolean cancelled = super.cancel(mayInterruptIfRunning);
        if (cancelled) {
            finishTask(true);
            if (cancelSource != null) cancelSource.run();
        }
        return cancelled;
    }

    @Override
    public boolean complete(T value) {
        boolean completed = super.complete(value);
        if (completed) finishTask(false);
        return completed;
    }

    @Override
    public boolean completeExceptionally(Throwable error) {
        boolean completed = super.completeExceptionally(error);
        if (completed) finishTask(false);
        return completed;
    }

    /** Unlike thenApply, cancelling this result also cancels its source task. */
    public <U> CompletableFuture<U> mapSwiftResult(Function<? super T, ? extends U> transform) {
        SwiftCompletableFuture<U> result = new SwiftCompletableFuture<>(() -> cancel(false));
        whenComplete((value, error) -> {
            if (error != null) result.completeExceptionally(error);
            else {
                try { result.complete(transform.apply(value)); }
                catch (Throwable failure) { result.completeExceptionally(failure); }
            }
        });
        return result;
    }

    private void finishTask(boolean cancel) {
        long handle;
        synchronized (taskLock) {
            handle = taskHandle;
            taskHandle = 0;
        }
        if (handle != 0) {
            if (cancel) cancelSwiftTask(handle);
            releaseSwiftTask(handle);
        }
    }

    private static native void cancelSwiftTask(long handle);
    private static native void releaseSwiftTask(long handle);
}
