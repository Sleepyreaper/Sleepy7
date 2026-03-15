# Sleepy7 Architecture

## Modules
- `CoreEngine`: Actor-based deterministic game rules.
- `MonetizationKit`: StoreKit 2 + AdMob + consent/ATT flow.
- `UI`: SwiftUI rendering (existing app target).
- `Networking`: reserved for remote sync and game services.

## Security Model

### In-App Purchases
- Local StoreKit verification is used only as immediate UX signal.
- Production entitlement truth must come from server verification of signed JWS transaction payloads.
- `IAPManager` exposes `EntitlementValidating` for backend integration.
- Persisted entitlements are defense-in-depth, not authority.

### Ads and Privacy
- UMP consent flow runs before ad SDK start.
- ATT authorization requested before ad initialization.
- Non-personalized ads use `npa=1`.
- `Info.plist` includes ATS hardening and SKAdNetwork IDs.

### CI/CD
- CI is read-only permissions.
- TestFlight workflow writes API key to temp file and removes it.
- No secrets committed to repo.

## Game Center Data Minimization
- Display name retrieval is gated behind explicit user consent.
- No transmission of display name to external services by default.