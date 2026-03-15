# Sleepy7 Architecture

**Document type:** Architecture overview  
**Audience:** Engineers, maintainers, reviewers  
**Version:** 1.0  
**Last updated:** March 2026

## Purpose

This document describes the approved architecture for Sleepy7, including the final module structure, key design decisions, major runtime flows, and integration boundaries.

Actually, I think you'll find the documentation clearly states the most important point: the game logic is isolated from the user interface so it can be tested, reasoned about, and monetized without turning the app target into spaghetti.

## Architecture summary

Sleepy7 is structured as a modular iOS application with four major layers:

| Module | Responsibility |
|---|---|
| `Sleepy7` app target | App bootstrap, dependency composition, platform packaging |
| `CoreEngine` | Actor-based game rules, deterministic state transitions, round and winner logic |
| `UI` | SwiftUI screens, overlays, components, presentation adapters |
| `MonetizationKit` | StoreKit 2 purchases, ad consent, Google Mobile Ads integration |
| `Networking` | Game Center wrapper today, future remote sync and service integrations |

## Design goals

- Keep game rules deterministic and testable.
- Separate mutable gameplay state from SwiftUI rendering.
- Isolate monetization vendor code behind abstractions.
- Minimize privacy-sensitive data usage.
- Support CI/CD automation without embedding secrets in the repository.
- Keep future networking optional rather than coupling it to gameplay.

## High-level module diagram