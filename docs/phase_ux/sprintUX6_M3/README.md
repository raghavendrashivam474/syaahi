# UX-06.M3 — Resonance Reply Submission & Interaction Completion

## Overview

This microsprint completes the Resonance Reply interaction flow. The reply
composer UI existed but lacked a visible submission action, leaving authors
unable to publish replies through the interface.

## Sprint Goal

A poem author can compose, submit, and view a Resonance Reply without
encountering an incomplete or ambiguous interaction state.

## Scope

- **S3.1** — Reply submission action (Post Reply button)
- **S3.2** — Submission lifecycle (loading, success, reset)
- **S3.3** — State & error handling (validation, failure, retry)
- **S3.4** — Reply display consistency (persistence, no duplicates)

## Acceptance Criteria Status

| ID | Criterion | Status |
|---|---|---|
| AC-01 | Post Reply action visible | ✅ |
| AC-02 | Empty/whitespace rejection | ✅ |
| AC-03 | Valid replies submit successfully | ✅ |
| AC-04 | Loading state during submission | ✅ |
| AC-05 | Duplicate submission prevention | ✅ |
| AC-06 | Reply appears against correct response | ✅ |
| AC-07 | Failed submissions preserve draft + allow retry | ✅ |
| AC-08 | Author-only reply permissions intact | ✅ |
| AC-09 | Reply length constraints intact (280 chars) | ✅ |
| AC-10 | Published replies persist after refresh | ✅ |
| AC-11 | Mobile and desktop layouts accessible | ✅ |
| AC-12 | Existing Resonance interactions unaffected | ✅ |

## Release Tag

`v-UX-06.M3`
