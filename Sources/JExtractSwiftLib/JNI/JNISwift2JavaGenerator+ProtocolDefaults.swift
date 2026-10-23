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

import SwiftExtract
import SwiftSyntax

extension JNISwift2JavaGenerator {
  struct ProtocolDefaultMethod {
    let requirement: ExtractedFunc
    let helper: ExtractedFunc
    let adapterName: String
  }

  /// Compare API signatures rather than local parameter names, which need not
  /// agree between a requirement and its extension implementation.
  func sameProtocolSignature(_ lhs: ExtractedFunc, _ rhs: ExtractedFunc) -> Bool {
    lhs.name == rhs.name && lhs.apiKind == rhs.apiKind
      && lhs.functionSignature.result == rhs.functionSignature.result
      && lhs.functionSignature.effectSpecifiers == rhs.functionSignature.effectSpecifiers
      && lhs.functionSignature.parameters.count == rhs.functionSignature.parameters.count
      && zip(lhs.functionSignature.parameters, rhs.functionSignature.parameters).allSatisfy {
        $0.argumentLabel == $1.argumentLabel && $0.type == $1.type
          && $0.convention == $1.convention && $0.isVariadic == $1.isVariadic
      }
  }

  /// Only unconditional defaults are valid for every Java implementor.
  private func isUnconditionalProtocolDefault(_ method: ExtractedFunc) -> Bool {
    guard !method.isProtocolRequirement, !method.isStatic,
      method.attributeList?.isEmpty != false,
      method.functionSignature.genericParameters.isEmpty,
      method.functionSignature.genericRequirements.isEmpty
    else { return false }
    var parent = method.swiftDecl.parent
    while let node = parent {
      if let ext = node.as(ExtensionDeclSyntax.self) {
        return ext.genericWhereClause == nil && ext.attributes.isEmpty
      }
      parent = node.parent
    }
    return false
  }

  func protocolDefaultMethods(of type: ExtractedNominalType) -> [ProtocolDefaultMethod] {
    if let cached = protocolDefaultMethodsCache[type] { return cached }
    // Reuse the callback translator's capability checks. Unsupported protocols
    // keep abstract Java requirements rather than acquiring invalid defaults.
    guard interfaceProtocolWrappers[type] != nil, type.attributeList.isEmpty else { return [] }
    let requirements = allProtocolRequirementMethods(of: type)
    guard
      requirements.allSatisfy({ method in
        guard case .instance(.byValue, _) = method.functionSignature.selfParameter else { return false }
        return method.apiKind == .function && !method.isAsync && !method.isIsolated
          && method.attributeList?.isEmpty != false
          && method.parentType?.asNominalType?.nominalTypeDecl.syntax.attributes.isEmpty != false
          && method.functionSignature.genericParameters.isEmpty
          && !method.functionSignature.hasVariadicParams
      })
    else { return [] }
    let candidates = type.methods.filter(isUnconditionalProtocolDefault)
    var defaults: [ProtocolDefaultMethod] = []
    for requirement in requirements {
      guard candidates.contains(where: { sameProtocolSignature($0, requirement) }),
        case .instance(.byValue, _) = requirement.functionSignature.selfParameter
      else { continue }
      let index = defaults.count
      let name = "__swiftDefault_\(type.effectiveOutputTypeName.fullFlatName)_\(index)"
      var signature = requirement.functionSignature
      signature.selfParameter = nil
      signature.parameters =
        [
          SwiftParameter(
            convention: .byValue,
            parameterName: "receiver",
            type: .existential(type.swiftType)
          )
        ]
        + signature.parameters.enumerated().map { index, parameter in
          var parameter = parameter
          parameter.argumentLabel = nil
          parameter.parameterName = "p\(index)"
          return parameter
        }
      let helper = ExtractedFunc(
        module: swiftModuleName,
        swiftDecl: requirement.swiftDecl,
        name: name,
        apiKind: .function,
        functionSignature: signature,
        sourceFilePath: requirement.sourceFilePath
      )
      guard var translated = translatedDecl(for: helper) else { continue }
      var companionName = type.effectiveJavaTypeName.components
      companionName[companionName.count - 1] += "$SwiftDefaults"
      translated.parentName = SwiftQualifiedTypeName(companionName)
      translatedDecls[helper] = translated
      defaults.append(
        ProtocolDefaultMethod(
          requirement: requirement,
          helper: helper,
          adapterName: name + "_Receiver"
        )
      )
    }
    protocolDefaultMethodsCache[type] = defaults
    return defaults
  }

  func protocolDefaultParameters(_ method: ExtractedFunc) -> [SwiftParameter] {
    method.functionSignature.parameters.enumerated().map { index, parameter in
      var parameter = parameter
      parameter.parameterName = "p\(index)"
      return parameter
    }
  }

  func protocolDefaultArguments(_ method: ExtractedFunc) -> String {
    protocolDefaultParameters(method).map { parameter in
      let label = parameter.argumentLabel.map { "\($0): " } ?? ""
      return label + (parameter.isInout ? "&" : "") + parameter.name
    }.joined(separator: ", ")
  }

  func protocolDefaultEffects(_ method: ExtractedFunc) -> String {
    if let error = method.functionSignature.thrownTypedError { return " throws(\(error))" }
    return method.isThrowing ? " throws" : ""
  }
}
