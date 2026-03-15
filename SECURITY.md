# Security

**Document type:** Security summary and compliance guide  
**Audience:** Engineers, release managers, reviewers  
**Version:** 1.0  
**Last updated:** March 2026

## Scope

This document summarizes the security and privacy posture of the approved Sleepy7 release. It incorporates final recommendations from the security review and explains how the app complies with current implementation expectations.

## Security objectives

- Protect purchase entitlements from trivial tampering.
- avoid collecting or exposing unnecessary user data
- prevent secret leakage in source control and build pipelines
- ensure ad behavior respects consent and platform requirements
- reduce unnecessary identity exposure from Game Center

## Summary of implemented controls

| Area | Control |
|---|---|
| In-app purchases | StoreKit 2 verification with optional server-authoritative entitlement hook |
| Entitlement caching | Local persistence used only as defense-in-depth |
| Ad consent | User Messaging Platform (UMP) flow before ad SDK start |
| Tracking permission | App Tracking Transparency prompt before personalized ad usage |
| Ad fallback | Non-personalized ad requests when consent is denied or unavailable |
| Transport security | App Transport Security enabled, arbitrary loads disabled |
| CI/CD secrets | GitHub Actions Secrets and temporary-file handling |
| Identity minimization | Game Center display name gated behind user disclosure/consent |
| Repository hygiene | Expanded `.gitignore` for signing artifacts, build outputs, and local config |

## Security review summary

Bob’s final recommendations fell into four main categories:

1. purchase hardening
2. ad compliance and consent
3. CI/CD secret handling
4. Game Center privacy minimization

The approved release addresses those areas as follows.

## 1. In-app purchase protection

### Risk addressed

On-device entitlement logic alone can be patched or bypassed on compromised devices.

### Current approach

Sleepy7 uses StoreKit 2 transaction verification and includes an abstraction for optional backend validation of signed transaction payloads.

### Control details

| Measure | Status | Notes |
|---|---|---|
| StoreKit 2 verification | Implemented | Verified transactions are required before entitlements are granted |
| Environment validation | Implemented | Sandbox and production environments are checked appropriately |
| Backend verification hook | Implemented | `EntitlementValidating` / verification client supports server-authoritative flows |
| Local entitlement storage | Implemented | Used as defense-in-depth, not as sole authority |
| Restore purchases | Implemented | Supports entitlement refresh across installs and devices where Apple allows |

### Important limitation

The server hook is present, but a full production backend is still an operational dependency outside this repository. The app is prepared for authoritative verification; deployment of that service must be completed for full revenue hardening.

## 2. Advertising compliance

### Risk addressed

Personalized advertising without appropriate consent can create regulatory and App Review risk.

### Current approach

Ads are initialized only after consent flow handling and App Tracking Transparency evaluation. Non-personalized ads are requested when personalization is not allowed.

### Control details

| Measure | Status | Notes |
|---|---|---|
| User Messaging Platform consent | Implemented in monetization layer | Required before ad startup where applicable |
| App Tracking Transparency | Implemented | Requested on supported iOS versions |
| Non-personalized ads (`npa=1`) | Implemented | Used when consent does not permit personalized ads |
| SKAdNetwork list | Implemented in `Info.plist` | Required for ad attribution support |
| AdMob identifiers | Configured via build settings | Not hard-coded in source |

## 3. CI/CD and secret handling

### Risk addressed

Release secrets, signing materials, or API keys can leak via workflows, logs, or committed config files.

### Current approach

The release workflows use GitHub Actions Secrets, restricted temporary files, artifact hygiene, and cleanup steps.

### Control details

| Measure | Status | Notes |
|---|---|---|
| Secrets in repository | Prohibited | Not stored in tracked files |
| App Store Connect key handling | Implemented | Written to temporary file with restrictive permissions |
| Temp-file cleanup | Implemented | Sensitive files removed after workflow completion |
| CI permissions | Minimized | Read-only by default for CI |
| `.gitignore` hardening | Implemented | Covers certificates, profiles, `xcconfig`, `ipa`, `xcresult`, and related files |

## 4. Game Center privacy minimization

### Risk addressed

Displaying or transmitting player identity without clear user expectation can create privacy issues.

### Current approach

Game Center authentication is supported, but display-name access is gated behind explicit local disclosure or consent handling. The display name is not shared externally by default.

### Control details

| Measure | Status | Notes |
|---|---|---|
| Authentication support | Implemented | Uses `GKLocalPlayer` authentication flow |
| Display-name minimization | Implemented | Returned only when local disclosure/consent has been acknowledged |
| External sharing by default | Not enabled | No default external transmission path documented |

## Privacy-related configuration

The following `Info.plist` entries are relevant to security and compliance:

| Key | Purpose |
|---|---|
| `NSAppTransportSecurity` | Prevents arbitrary network loads unless explicitly allowed |
| `NSUserTrackingUsageDescription` | Explains tracking permission request |
| `GADApplicationIdentifier` | AdMob integration |
| `ADMOB_BANNER_UNIT_ID` | Banner ad configuration |
| `ADMOB_REWARDED_UNIT_ID` | Rewarded ad configuration |
| `GKGameCenterIdentifier` | Game Center configuration |
| `SKAdNetworkItems` | Ad attribution support |
| `NSPhotoLibraryAddUsageDescription` | Screenshot export only if feature is enabled |

## Secure development expectations

Contributors should follow these rules:

- never commit secrets
- never rely on local purchase caches as sole entitlement authority
- never enable personalized ads without applicable consent and permission
- never broaden Game Center data usage without updating user-facing disclosures
- never weaken App Transport Security without documented review

## Incident handling guidance

If a security-relevant issue is discovered:

1. assess whether it affects purchases, privacy, secrets, or release integrity
2. disable or limit the affected feature if user harm or revenue leakage is likely
3. rotate exposed secrets immediately if any credential may have been logged or committed
4. update documentation and release notes
5. add regression tests or workflow guardrails where possible

## Known residual risks

| Risk | Current state |
|---|---|
| Fully authoritative purchase enforcement | Requires production backend service |
| Anti-tamper and jailbreak resistance | Not a primary control in this release |
| Future analytics expansion | Must be reviewed against privacy documentation before adoption |

## Reporting

For internal handling, report issues to the repository maintainers and release manager before public disclosure. If a public security policy is added later, link it from this document.

## Related documentation

- [README.md](README.md)
- [ARCHITECTURE.md](ARCHITECTURE.md)
- [CONTRIBUTING.md](CONTRIBUTING.md)
- [docs/monetization_guide.md](docs/monetization_guide.md)