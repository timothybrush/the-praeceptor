# Praeceptor Context Guidelines
## How to build The Praeceptor's understanding of you

---

## What the context system does

The Praeceptor holds two types of knowledge about you:

**Structured intake** — your name, what you're building, where you stand, your original thesis, current focus, last commitment, and the tension that keeps surfacing. You set this during onboarding. You can update it any time from Settings → Profile & Context.

**Supplemental context** — up to 2,000 characters of additional context you provide: an ICP profile, operating principles, role history, a chat export, anything that tells him more about who you are and what you're working through. This is the layer this document explains.

Both travel with every session. He sees them before he speaks.

---

## What to put in supplemental context

**High value:**
- Your Ideal Client Profile (ICP) — if you are building a service business, this tells him who you are building for and sharpens the lens on every acquisition, positioning, and pricing conversation
- AI chat exports — if you've had deep conversations with another AI about your situation, a compressed version of those insights can give him a head start
- Operating principles — rules you've made for yourself, constraints you've committed to, lines you don't cross
- Role history — compressed summary of what you've done, where you've operated, what you've built and what you've learned
- The thesis document — the original version of what you said this was, before any revisions
- Current financial snapshot — the runway number, the monthly burn, what you're depending on and for how long

**Lower value (skip these):**
- Resumés or LinkedIn bios — too formatted, too positional
- Business plans — too aspirational, not enough operational reality
- Long blog posts or essays — not context, content
- Meeting notes — too granular

---

## Token budget

The supplemental context field is capped at **2,000 characters (~500 tokens)**. The full knowing layer (structured intake + supplemental) targets **≤ 800 tokens** total so it fits within the conversation window without crowding the session.

If your context is longer, compress it before pasting. Use the pre-flight prompt below.

---

## Pre-flight prompt (for any AI)

If you have a longer document — a chat export, a role history, a planning document — run it through this prompt first to compress it to something the Praeceptor can use:

```
I need to compress the following into a 300–400 word context document for a mentor named The Praeceptor. 
He is a direct, Socratic mentor who needs operational truth, not positioning.

Focus on:
- What I'm actually building (not the pitch version)
- Where I actually stand (income, stability, pressure)
- What the original thesis was before any revisions
- The patterns I keep falling into
- What I say I'm going to do vs. what I actually do

Strip: credentials, accomplishments framed for social consumption, anything designed to present me positively rather than accurately.

Compress this to 300–400 words of operational truth:

[PASTE YOUR CONTENT HERE]
```

---

## Supported file formats

The app accepts `.txt` and `.json` files via direct upload or the iCloud folder sync.

**Recommended format:** Plain text (`.txt`). Write it like you're briefing someone — short sentences, present tense, operational specifics. Avoid markdown formatting; it wastes characters.

**JSON** is accepted for structured exports (ChatGPT data export, etc.). The app reads the raw content — if you're exporting JSON, compress it first with the pre-flight prompt and save the output as a `.txt` file.

---

## iCloud folder sync

You can drop files directly into **iCloud Drive → Praeceptor/** and sync them from within the app (Settings → Profile & Context → Sync from iCloud Folder).

The app reads all `.txt` and `.json` files in that folder, concatenates them in filename order, and loads them into the supplemental context field. Files are read at sync time — if you update a file in iCloud, sync again.

**Naming convention (optional but useful):**
```
01_icp.txt
02_thesis.txt
03_operating-principles.txt
```

Files are sorted alphabetically, so prefix numbers to control the order.

---

## Updating your context

**Structured intake** (name, thesis, focus, commitment, tension): update when your situation changes — new project, new income situation, a commitment you made or broke. Don't let it drift.

**Supplemental context**: treat it as a single document you maintain. When you have a major shift — a new thesis, a decision to abandon something, a financial inflection — update it. It doesn't stack; the last thing you save is what he sees.

**The test:** if you read it before a session and it accurately describes your situation, leave it. If it describes someone slightly more optimistic than you actually are right now, update it.

---

## Privacy

Context files stay on your device and in your personal iCloud account. They are sent to Claude (Anthropic's API) as part of each session prompt — the same data handling as any other conversation. Nothing is stored by Anthropic beyond the standard API data retention policy.

---

## Building the iCloud bridge with Claude Code (advanced)

If you use Claude Code, you can automate context updates:

1. Create `~/Library/Mobile Documents/iCloud~com~praeceptor~app/Documents/Praeceptor/` as your drop-in folder (or use iCloud Drive from Finder)
2. Write a prompt or hook that generates your context snapshot and writes it to `01_context.txt` in that folder
3. Sync in-app when you're ready for him to see it

The folder is just a standard iCloud Documents folder — any tool that can write files can update it.
