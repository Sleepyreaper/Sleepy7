# Contributing to Sleepy7

**Document type:** Contribution guide  
**Audience:** Engineers and maintainers  
**Version:** 1.0  
**Last updated:** March 2026

## Purpose

This guide explains how to contribute code safely and consistently to Sleepy7.

If you are here to “just make a quick change,” let me rephrase that in a way that’s useful to someone who wasn’t in the room: every change should be buildable, testable, reviewable, and understandable.

## Development principles

- Keep gameplay rules in `CoreEngine`, not in SwiftUI views.
- Keep monetization vendor code inside `MonetizationKit`.
- Prefer small, reviewable pull requests.
- Do not commit secrets, local signing material, or environment-specific configuration.
- Add or update documentation whenever behavior changes.
- Preserve user privacy by default.

## Prerequisites

- Xcode 15.4+
- iOS 17 simulator
- Swift 5.9
- Access to required GitHub repository settings for CI/CD if working on release automation
- Apple sandbox account for purchase testing when changing StoreKit flows

## Repository structure

| Path | Purpose |
|---|---|
| `Sleepy7/` | App target and app-specific code |
| `Packages/CoreEngine/` | Core game logic and tests |
| `Packages/MonetizationKit/` | Purchases, ads, consent, tests |
| `.github/workflows/` | Continuous integration and release workflows |
| `docs/` | End-user documentation |

## Coding standards

### Swift standards

- Use Swift 5.9 language features appropriately.
- Prefer `struct` for value types and `actor` for isolated mutable state.
- Keep types small and focused.
- Use explicit access control in package code.
- Favor descriptive names over abbreviated names.
- Avoid force unwraps unless failure is truly unrecoverable and documented.

### Style rules

| Rule | Expectation |
|---|---|
| Imports | Keep only required imports |
| Naming | Types in `UpperCamelCase`, members in `lowerCamelCase` |
| Control flow | Prefer early returns for invalid states |
| Comments | Explain why, not what |
| Concurrency | Keep mutable shared state inside actors or main-actor types |
| Privacy | Minimize personal data usage and document any new collection |

### Documentation standards

- Update `README.md` for feature or setup changes.
- Update `ARCHITECTURE.md` for module or flow changes.
- Update `SECURITY.md` when privacy, purchase, ad, or secret-handling behavior changes.
- Update `docs/monetization_guide.md` for user-visible purchase or ad changes.

If it’s not documented, it didn’t happen.

## Branching and pull requests

### Branch naming

Use one of the following conventions:

- `feature/<short-description>`
- `fix/<short-description>`
- `docs/<short-description>`
- `chore/<short-description>`

Examples:

- `feature/actor-engine`
- `fix/iap-entitlement-refresh`
- `docs/release-1-0`

### Pull request expectations

Every pull request should include:

1. a clear summary
2. linked issue or rationale
3. test evidence
4. screenshots for UI changes
5. documentation updates where needed

## Build and test commands

### Build the app