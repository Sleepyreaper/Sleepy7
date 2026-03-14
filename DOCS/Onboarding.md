# Sleepy7 Onboarding Guide

- **Document type:** Onboarding guide
- **Audience:** New engineers joining the Sleepy7 project
- **Last updated:** March 2026
- **Applies to:** v1.0.0+

Welcome. This guide is written for the person joining the team tomorrow, not the person who was in the room six months ago.

By the end of week 1, you should be able to:

- build the app locally
- run unit tests
- understand the high-level architecture
- locate assets in the asset catalog
- make a small safe change and open a pull request

---

## Project at a glance

Sleepy7 is an iOS card game implemented in Swift. The codebase is moving toward a clearer separation between:

- **domain logic** in models and rules
- **presentation logic** in view models
- **user interface** in SwiftUI views
- **services** for networking, onboarding, and system integrations

Read these first:

1. [`README.md`](../README.md)
2. [`CONTRIBUTING.md`](../CONTRIBUTING.md)
3. [`DOCS/CI_CD.md`](./CI_CD.md)

---

## Prerequisites

Install the following before opening the project:

- macOS
- **Xcode 15.4 or later**
- Apple command line tools
- **Homebrew**
- **XcodeGen**
- **SwiftLint**
- access to the GitHub repository
- Apple Developer access if you need signing, device testing, or TestFlight work

### Install local tools

### path: local shell