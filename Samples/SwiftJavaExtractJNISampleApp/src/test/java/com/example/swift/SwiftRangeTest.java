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
import org.swift.swiftkit.core.SwiftRange;

import static org.junit.jupiter.api.Assertions.*;

public class SwiftRangeTest {
    @Test
    void returnRange() {
        SwiftRange<Long> range = MySwiftLibrary.makeInt64Range();
        assertEquals(-10L, range.getLowerBound());
        assertEquals(20L, range.getUpperBound());
    }

    @Test
    void roundTripAndHalfOpenBounds() {
        SwiftRange<Long> input = new SwiftRange<>(-5L, 10L);
        SwiftRange<Long> result = MySwiftLibrary.int64Range(input);
        assertEquals(input.getLowerBound(), result.getLowerBound());
        assertEquals(input.getUpperBound(), result.getUpperBound());
        assertTrue(MySwiftLibrary.int64RangeContains(input, -5L));
        assertFalse(MySwiftLibrary.int64RangeContains(input, 10L));
    }

    @Test
    void emptyRange() {
        SwiftRange<Long> range = MySwiftLibrary.int64Range(new SwiftRange<>(7L, 7L));
        assertEquals(7L, range.getLowerBound());
        assertEquals(7L, range.getUpperBound());
        assertFalse(MySwiftLibrary.int64RangeContains(range, 7L));
    }

    @Test
    void integerBounds() {
        SwiftRange<Integer> range = MySwiftLibrary.int32Range(new SwiftRange<>(Integer.MIN_VALUE, Integer.MAX_VALUE));
        assertEquals(Integer.MIN_VALUE, range.getLowerBound());
        assertEquals(Integer.MAX_VALUE, range.getUpperBound());
    }

    @Test
    void platformAndUnsignedIntegerBounds() {
        SwiftRange<Long> signed = MySwiftLibrary.platformIntRange(new SwiftRange<>(-1L, 5L));
        assertEquals(-1L, signed.getLowerBound());
        assertEquals(5L, signed.getUpperBound());
        // UInt64.max is represented by Java's signed long bit pattern -1.
        SwiftRange<Long> unsigned = MySwiftLibrary.uint64Range(new SwiftRange<>(0L, -1L));
        assertEquals(0L, unsigned.getLowerBound());
        assertEquals(-1L, unsigned.getUpperBound());
        assertThrows(IllegalArgumentException.class, () -> MySwiftLibrary.uint64Range(new SwiftRange<>(-1L, 0L)));
    }

    @Test
    void reversedBoundsThrowForObjectPrimitiveAndVoidReturns() {
        SwiftRange<Long> invalid = new SwiftRange<>(10L, 5L);
        assertThrows(IllegalArgumentException.class, () -> MySwiftLibrary.int64Range(invalid));
        assertThrows(IllegalArgumentException.class, () -> MySwiftLibrary.int64RangeContains(invalid, 7L));
        assertThrows(IllegalArgumentException.class, () -> MySwiftLibrary.acceptInt64Range(invalid));
        assertThrows(IllegalArgumentException.class, () -> MySwiftLibrary.multipleRanges(invalid, invalid));
        assertThrows(IllegalArgumentException.class, () -> MySwiftLibrary.multipleRanges(new SwiftRange<>(0L, 1L), invalid));
        assertEquals(-10L, MySwiftLibrary.makeInt64Range().getLowerBound());
    }

    @Test
    void nullRangeAndNullBoundsThrow() {
        assertThrows(NullPointerException.class, () -> MySwiftLibrary.int64Range(null));
        assertThrows(NullPointerException.class, () -> new SwiftRange<Long>(null, 1L));
        assertThrows(NullPointerException.class, () -> new SwiftRange<Long>(0L, null));
    }

    @Test
    @SuppressWarnings({"rawtypes", "unchecked"})
    void erasedBoundTypesAreChecked() {
        SwiftRange invalid = new SwiftRange<>("a", "z");
        assertThrows(IllegalArgumentException.class, () -> MySwiftLibrary.int64Range(invalid));
    }

    @Test
    void floatingPointBounds() {
        SwiftRange<Double> range = MySwiftLibrary.doubleRange(new SwiftRange<>(-0.5, 1.25));
        assertEquals(-0.5, range.getLowerBound());
        assertEquals(1.25, range.getUpperBound());
        assertThrows(IllegalArgumentException.class, () -> MySwiftLibrary.doubleRange(new SwiftRange<>(Double.NaN, 1.0)));
        assertThrows(IllegalArgumentException.class, () -> MySwiftLibrary.doubleRange(new SwiftRange<>(0.0, Double.NaN)));
    }

    @Test
    void stringsUseSwiftOrdering() {
        // Swift treats canonically equivalent strings as equal (an empty range),
        // whereas Java compares their UTF-16 code units.
        String lower = "\u00E9";
        String upper = "e\u0301";
        assertTrue(lower.compareTo(upper) > 0);
        SwiftRange<String> result = MySwiftLibrary.stringRange(new SwiftRange<>(lower, upper));
        assertEquals(lower, result.getLowerBound());
        assertEquals(upper, result.getUpperBound());
        assertTrue(MySwiftLibrary.stringRangeIsEmpty(result));
        assertThrows(IllegalArgumentException.class, () -> MySwiftLibrary.stringRange(new SwiftRange<>("z", "a")));
    }

    @Test
    void swiftComparableBoundsDoNotRequireJavaComparable() {
        try (var arena = SwiftArena.ofConfined()) {
            RangeBound lower = RangeBound.init(1L, arena);
            RangeBound upper = RangeBound.init(5L, arena);
            SwiftRange<RangeBound> result = MySwiftLibrary.customBoundRange(new SwiftRange<>(lower, upper));
            assertEquals(1L, result.getLowerBound().getValue());
            assertEquals(5L, result.getUpperBound().getValue());
            assertThrows(IllegalArgumentException.class, () -> MySwiftLibrary.customBoundRange(new SwiftRange<>(upper, lower)));
        }
    }
}
