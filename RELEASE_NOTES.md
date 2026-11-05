# POKET Release Notes

## Version 1.0.160 (Build 361) — November 5, 2026

### 🚀 Highlights & Native iOS Release
- **Day-Based Course Progression & Level Decoupling**: User level and citadel home progression are strictly anchored to completed daily lessons (`day`) with pocket score serving as the pass mark floor. Replaying lessons or high scores no longer artificially jump user levels.
- **Pocket Talk Decoupling**: Completely separated Pocket Talk challenges from Pocket Mate friend requests across swiper cards, profile widgets, and conversation tiles.
- **Premature Green Ring Fix**: Spoken Pact avatar indicator strictly awaits recipient acceptance.
- **Multi-Language Spoken Pact Agreement**: Fully localized agreement terms and modal sheets across Malayalam, Tamil, Hindi, and English.
- **CI/CD Pipeline Artifact Colon Fix**: Standardized IPA output path (`pocket_mates_app.ipa`) to ensure flawless GitHub Actions artifact upload and native TestFlight delivery via `altool`.

---

## Version 1.0.159 (Build 334) — November 4, 2026

### 🚀 Highlights & CI/CD Pipeline Correction
- **iOS CI/CD Pipeline Error Propagation**: Refined TestFlight upload step in `.github/workflows/shorebird-ios.yml` to execute verbose `altool` delivery and capture authentic exit codes without false green ticks.
- **Version Bump**: Upgraded to `1.0.159+334` for automated Shorebird release compilation and TestFlight delivery via GitHub Actions.

---

## Version 1.0.158 (Build 333) — November 4, 2026

### 🚀 Highlights & New Features

#### 1. Dedicated Ads 📺 Management & Diagnostics Tab (Admin Panel)
- **Centralized Ad Management**: Added a dedicated 21st tab in the Admin Panel (`AdminAdsManagementTab`) for real-time monitoring and inspection of all AdMob placements.
- **Independent Ad Unit Safe Testing**: Administrators can test any individual ad placement directly with a single click, viewing immediate status chips (`Testing...`, `Loaded Successfully`, `Failed (Code)`).
- **Runtime Placement Toggles**: Independent ON/OFF toggles for each of the 12 ad units to enable or disable individual placements instantly without waiting for app store releases.
- **Live Diagnostics & Telemetry**:
  - SDK initialization status indicator.
  - Counters for Total Requests, Successful Impressions, Clicks, and Load Failures.
  - VIP ad suppression counter tracking every ad suppressed for Premium / VIP users.
- **Admin Ad Preview Mode**: Temporary testing override allowing administrators to preview ads even when logged in as VIP/Admin.

#### 2. Cross-Platform iOS & Android AdMob Alignment
- **Complete iOS Unit Mapping**: Full integration of all 12 official iOS AdMob units alongside Android:
  - **Banner Placements (5)**: Ranking, Reels, Vibes, Home, Learning Review.
  - **Interstitial Placements (3)**: Learning Step, Day Completion, Attack Interstitial.
  - **Rewarded Placement (1)**: Store Coins (+50 Coins reward flow).
  - **Native Placements (3)**: Ranking Leaderboard, Discovery Feed, Profile Overview.
- **Strict VIP Zero-Ad Guarantee**: Multi-layered suppression checks ensuring VIP and Premium subscribers never see any ads.

#### 3. Menu & Experience Cleanup
- **Drawing Tool Temporarily Hidden**: Cleaned up the Tools menu by temporarily hiding the legacy Drawing Tool option while fully preserving all user sketches and underlying studio architecture.
- **Shorebird CI/CD Automation**: Updated version to `1.0.158+333` for automated GitHub Actions build, Shorebird release registration, and TestFlight deployment.

---
