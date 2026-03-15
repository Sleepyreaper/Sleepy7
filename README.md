# Sleepy7

> A SwiftUI card game built for iOS with deterministic core gameplay, optional Game Center integration, and consent-aware monetization.

**Version:** 1.0  
**Last updated:** March 2026  
**Platform:** iOS 17+  
**Language:** Swift 5.9

## Overview

Sleepy7 is a fast, turn-based card game for iPhone built around risk, memory, and score optimization.

Players draw numbered cards while avoiding duplicate values that cause a bust. The first player to reach seven unique numbers wins the round immediately. If no one flips seven, the highest non-busted score wins when the round ends. The app includes local play, artificial intelligence (AI) opponents, statistics tracking, Game Center authentication support, and a monetization layer for in-app purchases and advertising.

## Features

| Area | Included |
|---|---|
| Core gameplay | Turn-based card game with hit/stay flow |
| Game rules | Duplicate-number busting, unique-number tracking, round scoring |
| Engine design | Actor-based `GameEngine` in `CoreEngine` package |
| Artificial intelligence (AI) | Deterministic AI support for automated opponents |
| User interface | SwiftUI screens for menu, gameplay, rules, stats, overlays |
| Stats | Local game statistics tracking |
| Purchases | StoreKit 2 for Ad-Free and Premium Themes |
| Advertising | Google Mobile Ads banner and rewarded ad support |
| Privacy controls | App Tracking Transparency (ATT), User Messaging Platform (UMP), non-personalized ads |
| Social integration | Game Center authentication with display-name minimization |
| Delivery pipeline | GitHub Actions continuous integration (CI), Fastlane TestFlight release flow |

## Repository layout