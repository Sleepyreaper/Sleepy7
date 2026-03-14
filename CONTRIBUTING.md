# Contributing to Sleepy7

- **Document type:** Contributor guide
- **Audience:** Engineers, reviewers, maintainers
- **Last updated:** March 2026
- **Applies to:** v1.0.0+

Thank you for contributing to Sleepy7.

This document defines how we build, review, and merge changes so the repository remains understandable, testable, and safe. Actually, I think you'll find the documentation clearly states that "works on my machine" is not a merge strategy.

---

## Principles

- Prefer clarity over cleverness
- Keep domain logic out of SwiftUI views
- Use Swift Concurrency before introducing Combine
- Do not bypass architectural boundaries for convenience
- Write tests for rules, edge cases, and security-sensitive paths
- If you change behavior, update the documentation in the same pull request

---

## Repository Conventions

### File formatting rule

Per repository workflow rules, when proposing code in team handoff documents or implementation notes, every file must be formatted as:

### path/to/file.ext