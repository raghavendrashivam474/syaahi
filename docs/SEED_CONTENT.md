# 🪶 Syaahi — Seed Content

This document explains the seed accounts and content created for
local development and staging environments.

---

## Purpose

When a new developer sets up Syaahi locally, the database is empty.
An empty feed does not represent the product accurately.

These seed accounts and poems exist to:

- Make the feed feel alive during development and testing
- Cover a range of languages, emotions, and themes
- Verify that multi-author feeds display correctly
- Provide realistic content for UI and UX evaluation

---

## Environments

```text
✅ Local development
✅ Staging (once deployed)
❌ Production — real users only
Resetting Seed Data
To wipe and recreate all seed content at any time:

Bash

cd syaahi-backend
npx tsx scripts/cleanup-and-reseed.ts
This will delete all seed accounts and poems and recreate them fresh
with a randomised order.

Seed Accounts
#	Display Name	Username	Style
1	Raghav	raghav_writes	General
2	Midnight	midnight_writer	Introspective
3	Sara	sara_writes	Emotional
4	Arjun	arjun_kavya	Romantic
5	Zara	zara_lafz	Lyrical
6	Aarav	aarav_thinks	Philosophical
7	Meera	meera_writes	Romantic
8	Kabir	kabir_outdoors	Nature
9	Ananya	ananya_heals	Healing
10	Rizwan	rizwan_recalls	Nostalgic
Credentials are stored in a separate local document.
They are never committed to the repository.

Seed Poems
raghav_writes
Title	Language	Emotion	Theme
पहली बारिश	HINDI	LONGING	nature
Still Here	ENGLISH	HOPE	writing
खामोशी	HINDI	SOLITUDE	silence
midnight_writer
Title	Language	Emotion	Theme
3 बजे	HINDI	SOLITUDE	night
Gravity	ENGLISH	LONGING	loss
कल	HINDI	HOPE	tomorrow
sara_writes
Title	Language	Emotion	Theme
Unsent	ENGLISH	LONGING	letters
Small Things	ENGLISH	GRATITUDE	everyday
अधूरी बात	HINDI	LONGING	unspoken
arjun_kavya
Title	Language	Emotion	Theme
The Reader	ENGLISH	LOVE	books
वापसी	HINDI	HOPE	people
Enough	ENGLISH	HOPE	self
zara_lafz
Title	Language	Emotion	Theme
इश्क़	HINDI	LOVE	love
Midnight Chai	ENGLISH	SOLITUDE	night
यादें	HINDI	LONGING	memories
aarav_thinks
Title	Language	Emotion	Theme
Who Were You	ENGLISH	HOPE	identity
समय	HINDI	SOLITUDE	time
The Question	ENGLISH	HOPE	existence
meera_writes
Title	Language	Emotion	Theme
तुम्हारा इंतज़ार	HINDI	LOVE	waiting
Your Handwriting	ENGLISH	LONGING	memories
पहली मुलाक़ात	HINDI	LOVE	love
kabir_outdoors
Title	Language	Emotion	Theme
River Logic	ENGLISH	HOPE	rivers
बारिश के बाद	HINDI	GRATITUDE	rain
November	ENGLISH	SOLITUDE	seasons
ananya_heals
Title	Language	Emotion	Theme
Slowly	ENGLISH	HOPE	healing
शुक्रगुज़ार	HINDI	GRATITUDE	gratitude
New Soil	ENGLISH	HOPE	new beginnings
rizwan_recalls
Title	Language	Emotion	Theme
पुरानी गलियाँ	HINDI	LONGING	nostalgia
City at 6am	ENGLISH	SOLITUDE	city
माँ की रसोई	HINDI	LONGING	home
Coverage
text

Total Accounts : 10
Total Poems    : 30
Languages      : HINDI, ENGLISH
Emotions       : LOVE, LONGING, HOPE, SOLITUDE, GRATITUDE
Themes         : nature, writing, silence, night, loss,
                 tomorrow, letters, everyday, unspoken,
                 books, people, self, love, memories,
                 identity, time, existence, waiting,
                 rivers, rain, seasons, healing,
                 gratitude, new beginnings, nostalgia,
                 city, home
