# Sleepy7

> A modern iOS implementation of a push-your-luck card game inspired by Flip 7, built with SwiftUI, a Model-View-ViewModel (MVVM) architecture, and an actor-isolated game engine.

- **Repository:** `sleepyreaper/sleepy7`
- **Platform:** iOS 17+
- **Language:** Swift 5.9+
- **Last updated:** March 2026
- **Applies to:** v1.0.0+

## Overview

Sleepy7 is a polished iPhone and iPad card game centered on a simple but tense decision loop:

- Draw another card and press your luck
- Stop and bank your score
- Avoid drawing a duplicate number
- Reach seven unique numbers to trigger **Flip 7**

The app uses:

- **SwiftUI** for the user interface
- **Model-View-ViewModel (MVVM)** for presentation logic
- **Swift Concurrency** with an actor-based game engine
- **GitHub Actions** for continuous integration and TestFlight delivery
- **Game Center** and service abstractions for future multiplayer support

This repository is structured as an iOS application first, with the architecture designed to support gradual extraction into more modular packages over time.

---

## Game Rules: Flip 7 in Sleepy7

> **Important:** Physical versions of Flip 7 may vary by publisher printing, retailer summary, or house rules. Sleepy7 treats configurable rules as an architectural requirement. Official published rules should remain the source of truth when rule behavior is disputed.

### Core round objective

Players try to build a scoring hand by drawing **unique number cards**.

A round typically works like this:

1. A player chooses **Hit** or **Stay**
2. If they draw a **new number**, it is added to their round hand
3. If they draw a **duplicate number already in their hand**, they usually **bust**
4. A busted player typically scores **0 points for the round**
5. If a player collects **7 unique numbers**, they trigger **Flip 7**
6. Action and modifier cards can interrupt, protect, or increase scoring

### Number cards

- There is **one `0` card**
- For each number from **1 through 12**, the deck contains that many copies
  - Example: one `1`, two `2`s, three `3`s, and so on through twelve `12`s
- A number only helps if it is **unique in your current hand**
- Drawing a duplicate of a number already in your hand is normally a bust

### Action cards

Sleepy7 currently models these action cards:

- **Freeze**  
  Prevents a target player from voluntarily drawing further cards in the round

- **Flip Three**  
  A special action that flips additional cards according to the rules engine behavior

- **Second Chance**  
  Protects the player from one duplicate bust

### Modifier cards

Sleepy7 currently models these modifiers:

- `x2`
- `+2`
- `+4`
- `+6`
- `+8`
- `+10`

### Scoring

A non-busted hand scores as follows:

1. Sum all unique number cards in the hand
2. If the hand includes `x2`, double the total
3. Add all flat modifiers such as `+4` or `+10`
4. If the player triggered **Flip 7**, add the Flip 7 bonus

In the current implementation context, **Flip 7 adds 15 bonus points**.

### Rule edge cases intentionally designed for configuration

The architecture is designed to support future `RulesConfiguration` toggles for variant support, including:

- whether **Second Chance** auto-consumes or is optional
- how **Flip Three** resolves if a duplicate appears mid-sequence
- whether **Freeze** blocks only voluntary draws
- modifier stacking order
- deck exhaustion behavior
- whether Flip 7 immediately ends the round or grants only a bonus
- family-friendly variants such as reduced take-that interactions

---

## Architecture

Sleepy7 follows a **SwiftUI + MVVM + actor-isolated game engine** approach.

### High-level architecture diagram