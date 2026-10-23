# Upstream PR dependencies

This fork collects fixes for contribution to
[swiftlang/swift-java](https://github.com/swiftlang/swift-java). This graph tracks
the prerequisites for submitting and merging those fixes **upstream**. It does
not describe PR bases, merge order, or merge status in `qoncept/swift-java`.

Snapshot: 2026-10-23. Upstream `main` is
[`301e3da`](https://github.com/swiftlang/swift-java/commit/301e3da710ede7af93e798f1ce1c7950715a5748).
Only fixes not yet merged upstream are included. Fixes are tracked primarily by
their **origin PRs in `qoncept/swift-java`**. Corresponding upstream PR numbers
and statuses are labeled separately.

## Dependency graph

An arrow points from a **prerequisite** to the **fix that requires it**. Fixes in
the left-hand group can each target upstream `main` independently. Each node is
identified by its origin PR; the arrows still represent upstream prerequisites.

```mermaid
flowchart LR
    subgraph independent["Can target upstream main independently"]
        MAIN_ACTOR["qoncept/swift-java#1<br/>Synchronous MainActor thunks<br/>Upstream #938 — open"]
        PROTOCOL_EXT["qoncept/swift-java#2<br/>Exclude protocol extension members<br/>Upstream PR pending"]
        ACTOR_PROPERTIES["qoncept/swift-java#4<br/>Synchronous actor property witnesses<br/>Upstream PR pending"]
        FOUNDATION["qoncept/swift-java#5<br/>Foundation values in protocol callbacks<br/>Upstream PR pending"]
    end

    PROTOCOL_NAMES["qoncept/swift-java#3<br/>Consistent inherited requirement names<br/>Upstream PR pending"]
    PROTOCOL_EXT -->|"requires requirement classification"| PROTOCOL_NAMES
```

## Origin tracking and upstream PRs

The source branches and commits identify each proposed patch; they do not add
dependencies to the graph.

| Origin PR (`qoncept/swift-java`) | ID | Scope | Upstream PR (`swiftlang/swift-java`) | Source branch | Source commit |
| --- | --- | --- | --- | --- | --- |
| [#1](https://github.com/qoncept/swift-java/pull/1) | `MAIN_ACTOR` | Preserve `@MainActor` isolation in synchronous JNI thunks and generic openers. | [#938](https://github.com/swiftlang/swift-java/pull/938) (open) | `codex/fix-jni-main-actor-thunks` | [`f6c879d`](https://github.com/qoncept/swift-java/commit/f6c879d5c3e43d23917ecffd2a6b9f3e1624efaa) |
| [#2](https://github.com/qoncept/swift-java/pull/2) | `PROTOCOL_EXT` | Distinguish protocol-body requirements from extension implementations when generating callback interfaces and boxes. | Not opened | `codex/fix-jni-protocol-extension-requirements` | [`12a26cd`](https://github.com/qoncept/swift-java/commit/12a26cd67e8e3052553ff54db856a822febb941b) |
| [#3](https://github.com/qoncept/swift-java/pull/3) | `PROTOCOL_NAMES` | Keep requirement names consistent across Java interfaces, inherited box methods, and JNI dispatch thunks. | Not opened | `codex/fix-jni-protocol-requirement-names` | [`c47f646`](https://github.com/qoncept/swift-java/commit/c47f64619346f418d9c278743b77ed2d8756ac19) |
| [#4](https://github.com/qoncept/swift-java/pull/4) | `ACTOR_PROPERTIES` | Preserve synchronous access to explicit `nonisolated` actor properties and immutable protocol getter witnesses. | Not opened | `codex/fix-jni-actor-property-witnesses` | [`07e66d9`](https://github.com/qoncept/swift-java/commit/07e66d937526eb957ce97cf083732ee61f70d002) |
| [#5](https://github.com/qoncept/swift-java/pull/5) | `FOUNDATION` | Bridge `Data`, `Date`, `URL`, and `UUID` through JNI protocol callbacks. | Not opened | `codex/fix-jni-foundation-callbacks` | [`06061b0`](https://github.com/qoncept/swift-java/commit/06061b09f87b90cb8f9fb555539748fc7cce26d3) |

## Why these dependencies exist

- **`PROTOCOL_EXT` → `PROTOCOL_NAMES`:** `PROTOCOL_EXT` introduces
  `ExtractedFunc.isProtocolRequirement` and filters
  `supportedProtocolRequirements(of:)` with it. `PROTOCOL_NAMES` builds its
  overload disambiguation and declaring-interface naming on that filtered set.
  Its patch requires `PROTOCOL_EXT`; it does not require `MAIN_ACTOR`.
- **`MAIN_ACTOR` is independent:** it annotates synchronous thunks and generic
  openers and checks the caller's executor. It does not use the other fixes.
- **`ACTOR_PROPERTIES` is independent:** it adds
  `SwiftFunctionSignature.nonisolatedWitnessProtocol` and reads actor properties
  through that protocol. It uses neither the new protocol-requirement classifier
  nor the `MAIN_ACTOR` thunk changes.
- **`FOUNDATION` is independent:** it extends the existing callback conversions
  and adds the `JavaUtilUUID` runtime projection. It does not require protocol
  extension filtering, requirement-name changes, or either isolation fix.

These relationships were checked against the source patches. The four
independent patches each pass `git apply --check` against upstream `301e3da`.
`PROTOCOL_NAMES` does not apply to that baseline alone, and passes the same check
after applying `PROTOCOL_EXT`. Patch applicability supports the source analysis;
it is not a substitute for compiling and testing each upstream submission.

## Upstream submission order

1. `MAIN_ACTOR` is already submitted as upstream #938. `PROTOCOL_EXT`,
   `ACTOR_PROPERTIES`, and `FOUNDATION` can each be submitted against upstream
   `main` without waiting for #938 or for one another.
2. Submit `PROTOCOL_NAMES` after `PROTOCOL_EXT` merges upstream, or submit it as
   a stacked PR with an explicit dependency on the upstream `PROTOCOL_EXT` PR.
   Keep the naming PR's diff limited to its own changes, then rebase onto
   upstream `main` and retarget after the prerequisite merges.

Shared files and merge conflicts may require rebasing; they do not by themselves
create a prerequisite. When adding a fix, record its origin PR, corresponding
upstream PR (or pending status), descriptive ID, source commit, and the code-level
reason for every new edge. Update pending upstream PR links and statuses as
submissions progress. Merging a fix in this fork does not mark it merged upstream.
