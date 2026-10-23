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
import static org.junit.jupiter.api.Assertions.*;

public class EnumCaseCollisionTest {
    @Test
    void renamedRecordsPreserveTheirPayloads() {
        try (var arena = SwiftArena.ofConfined()) {
            var value = EnumCaseCollision.enumCaseCollision(42, arena);
            var payload = assertInstanceOf(EnumCaseCollision.Case.EnumCaseCollisionCase.class, value.getCase());
            assertEquals(42, payload.arg0());
            var keyword = EnumCaseCollision.case_(7, arena);
            assertEquals(7, assertInstanceOf(EnumCaseCollision.Case.CaseCase.class, keyword.getCase()).arg0());
            var plain = EnumCaseCollision.plain(9, arena);
            assertEquals(9, assertInstanceOf(EnumCaseCollision.Case.Plain.class, plain.getCase()).arg0());
        }
    }
}
