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

import CodePrinting
import Foundation
import JExtractSwiftLib
import SwiftJavaConfigurationShared
import Testing

@Suite
struct JNIProtocolParameterOverloadTests {
  @Test("Overloads share one adapter per protocol parameter")
  func identicalAdaptersAreEmittedOnce() throws {
    var config = Configuration()
    config.swiftModule = "SwiftModule"
    config.enableJavaCallbacks = true
    let analyzer = makeSwiftJavaAnalyzer(config: config)
    try analyzer.analyze(
      path: "/fake/Overloads.swiftinterface",
      text: """
        public protocol Callback { func value() -> Int64 }
        public struct Client {
          public init(store: some Callback)
          public init(store: some Callback, extra: Int64)
        }
        public func use(_ callback: some Callback)
        public func use(_ callback: some Callback, extra: Int64)
        public func other(_ callback: some Callback)
        """
    )
    let generator = JNISwift2JavaGenerator(
      config: config,
      translator: analyzer,
      javaPackage: "com.example.swift",
      swiftOutputDirectory: "/fake",
      javaOutputDirectory: "/fake",
      javaClassLookupTable: [:],
      moduleJavaPackages: [:]
    )
    var printer = SwiftPrinter(mode: .accumulateAll)
    try generator.writeSwiftThunkSources(&printer)
    let output = printer.finalize()
    for name in ["_Client_init_store_Wrapper", "_SwiftModule_use_callback_Wrapper", "_SwiftModule_other_callback_Wrapper"] {
      #expect(output.components(separatedBy: "final class \(name):").count - 1 == 1)
    }
  }
}
