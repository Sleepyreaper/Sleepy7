# Sleepy7 CI/CD Guide

- **Document type:** Operations and delivery guide
- **Audience:** Engineers, release managers, maintainers
- **Last updated:** March 2026
- **Applies to:** GitHub Actions-based iOS pipeline for v1.0.0+

This document explains the planned GitHub Actions pipeline for Sleepy7, how to trigger TestFlight builds, and which environment variables and secrets are required.

Snake’s summary, translated into language a future maintainer can actually use: the team is using **GitHub Actions**, not **Xcode Cloud**, because it is more controllable, easier to script, and easier to cap for cost.

---

## Overview

The Sleepy7 continuous integration and continuous delivery setup is designed to:

1. lint the codebase
2. build the app for testing
3. run automated tests
4. archive a release build
5. export an `.ipa`
6. upload the build to **TestFlight**
7. optionally manage beta tester groups
8. publish build and test summaries to the GitHub job summary

### Pipeline diagram