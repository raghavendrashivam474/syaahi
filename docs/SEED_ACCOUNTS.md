# 🪶 Syaahi — Seed Content

## Version: v0.2.2

This document describes the development seed dataset used by Syaahi for local development, staging verification, UI validation, onboarding, and demonstrations.

The seed dataset exists to ensure the application always contains realistic content and can be evaluated without requiring manual account creation.

---

# Purpose

When a developer clones Syaahi for the first time, the database is empty.

An empty feed creates several problems:

* The application appears unfinished
* Feed rendering cannot be evaluated properly
* Pagination cannot be tested
* Multi-author scenarios cannot be verified
* Demonstrations feel unrealistic

The seed dataset solves these problems.

---

# Environment Usage

| Environment       | Seed Content |
| ----------------- | ------------ |
| Local Development | ✅ Enabled    |
| Staging           | ✅ Enabled    |
| Production        | ❌ Disabled   |

Production must contain only real user-generated content.

Seed accounts must never be exposed as production users.

---

# Dataset Summary

Current Dataset:

```text
Accounts  : 10
Poems     : 30
Languages : HINDI, ENGLISH
```

Emotion Coverage:

```text
LOVE
LONGING
HOPE
SOLITUDE
GRATITUDE
```

The dataset intentionally includes:

* Multiple writing styles
* Multiple authors
* Multiple emotions
* Mixed poem lengths
* Hindi and English content

---

# Seed Accounts

These accounts are development assets.

Their purpose is to create realistic feed activity and support testing.

Credentials are maintained separately and are never committed to the repository.

---

## raghav_writes

Display Name:

Raghav

Style:

General Writing

Themes:

* Reflection
* Writing
* Daily Thoughts

---

## midnight_writer

Display Name:

Midnight

Style:

Introspective

Themes:

* Late Night Thoughts
* Silence
* Solitude

---

## sara_writes

Display Name:

Sara

Style:

Emotional

Themes:

* Relationships
* Vulnerability
* Personal Reflection

---

## arjun_kavya

Display Name:

Arjun

Style:

Romantic

Themes:

* Love
* Waiting
* Distance

---

## zara_lafz

Display Name:

Zara

Style:

Lyrical

Themes:

* Imagery
* Language
* Memory

---

## aarav_thinks

Display Name:

Aarav

Style:

Philosophical

Themes:

* Time
* Identity
* Growth

---

## meera_writes

Display Name:

Meera

Style:

Romantic

Themes:

* Love
* Memories
* Longing

---

## kabir_outdoors

Display Name:

Kabir

Style:

Nature

Themes:

* Rain
* Rivers
* Seasons

---

## ananya_heals

Display Name:

Ananya

Style:

Healing

Themes:

* Gratitude
* Recovery
* Hope

---

## rizwan_recalls

Display Name:

Rizwan

Style:

Nostalgic

Themes:

* Old Memories
* City Life
* Reflection

---

# Seed Content Strategy

The dataset is intentionally designed to simulate a small but active platform.

Objectives:

* Multiple authors visible in feed
* Emotion variety
* Language variety
* Natural publication order
* Realistic content density

The goal is not volume.

The goal is realism.

---

# Feed Validation Coverage

The current dataset exists specifically to validate:

### Feed Rendering

* Multi-author feed display
* Author metadata display
* Title rendering
* Emotion rendering
* Language rendering

### Pagination

* Cursor pagination
* Infinite scrolling
* End-of-feed handling
* Refresh behaviour

### Reader Experience

* Poem reader layout
* Author attribution
* Long-form content rendering

---

# Seed Reset System

Location:

```text
syaahi-backend/scripts/cleanup-and-reseed.ts
```

Run:

```bash
npx tsx scripts/cleanup-and-reseed.ts
```

---

# What The Script Does

The script performs a complete reset of development content.

Steps:

1. Deletes existing seed accounts
2. Deletes existing seed poems
3. Recreates all seed users
4. Recreates all seed poems
5. Randomizes author order
6. Staggers timestamps naturally
7. Produces a consistent testing environment

This allows any developer to recreate the dataset in seconds.

---

# Timestamp Strategy

Poems are intentionally distributed across time.

Instead of:

```text
All poems created at once
```

The script creates:

```text
Natural publication timeline
```

Benefits:

* More realistic feed ordering
* Better pagination testing
* Improved demonstration quality

---

# Development Rules

Seed content may:

✅ Be recreated

✅ Be expanded

✅ Be updated

✅ Be replaced

Seed content must not:

❌ Exist in production

❌ Represent real user data

❌ Be treated as permanent records

---

# Future Expansion

Target future dataset:

```text
20 Users
100 Poems
```

Potential emotion additions:

```text
NOSTALGIA
HEALING
REGRET
COURAGE
DREAMS
```

Potential language additions:

```text
URDU
HINGLISH
```

Expansion should preserve author identity and writing style consistency.

---

# Related Documents

For additional context, see:

```text
docs/ARCHITECTURE.md
docs/API_CONTRACT.md
docs/DECISIONS.md
docs/PROGRESS.md
```

---

# Summary

Current Seed Dataset:

```text
10 Writers
30 Poems
5 Core Emotions
2 Languages
Reusable Reset Script
```

Purpose:

Provide a realistic, repeatable, and maintainable development environment that accurately represents the Syaahi reading experience.
