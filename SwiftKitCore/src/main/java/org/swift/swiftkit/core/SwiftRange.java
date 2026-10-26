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

package org.swift.swiftkit.core;

import java.util.Objects;

/**
 * A half-open Swift range, including its lower bound and excluding its upper bound.
 * The bounds live on the Java heap; this container does not own native memory.
 * Bounds that wrap Swift objects retain those objects' normal lifetime requirements.
 * <p>
 * Swift validates the bound types and ordering when the range is passed to Swift.
 * This class deliberately does not require {@link Comparable}: Swift's ordering
 * need not match Java's, and a Swift bound's wrapper need not implement it.
 * Equal bounds represent an empty range.
 *
 * @param <T> the Java representation of the Swift bound type
 */
public final class SwiftRange<T> {
    private final T lowerBound;
    private final T upperBound;

    /**
     * Create a range to pass to Swift. Swift rejects reversed or unordered bounds
     * with {@link IllegalArgumentException} before calling the target function.
     *
     * @throws NullPointerException if either bound is null
     */
    public SwiftRange(T lowerBound, T upperBound) {
        this.lowerBound = Objects.requireNonNull(lowerBound, "lowerBound must not be null");
        this.upperBound = Objects.requireNonNull(upperBound, "upperBound must not be null");
    }

    /** Return the inclusive lower bound. */
    public T getLowerBound() {
        return lowerBound;
    }

    /** Return the exclusive upper bound. */
    public T getUpperBound() {
        return upperBound;
    }
}
